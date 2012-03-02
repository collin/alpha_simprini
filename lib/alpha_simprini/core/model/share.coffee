AS = require "alpha_simprini"
AS.Core.require "model"
_ = require "underscore"
sharejs = require("share").client

class ShareMixin extends AS.Mixin
  extends: (klass, type) ->
    klass._type = type
    super(klass)

AS.Model.Share = new ShareMixin
  LifeCycle: class LifeCycle
    AS.StateMachine.extends(this)

  mixed_in: ->
    @define_callbacks before: ["open"], after: ["open", "load"]

    @before_initialize (model) ->
      model.needs_indexing = true
      model.loaded_data = {}
      model.embedded_data = {}
      model.share_bindings = []

    @after_initialize (model) ->
      model.share_namespace = ".#{model.attributes.id}-share"

  class_methods:
    index: (name, config) ->
      @write_inheritable_value 'indeces', name, config
      @::[name] = -> @["#{name}_indexer"] ?= @indexer(name)

    open: (id=AS.uniq(), indexer=(model) -> model.did_index()) ->
      model = AS.All.byId[id] or new this(id:id)
      model.run_callbacks("before_open")
      AS.open_shared_object id, (share) ->
        model.did_open(share)
        model.run_callbacks("after_open")
        indexer(model)
      model

    load: (id, callback) ->
      unless model = AS.All.byId[id]
        model = AS.All.byId[id] or new this(id:id)
      callback ?= model.did_load
      AS.open_shared_object id, _.bind(callback, model)
      model

    embedded: (id, share) ->
      model = AS.All.byId[id] or new this(id:id)
      model.did_load_embedded(share)
      model

  instance_methods:
    did_open: (@share) ->
      @ensure_defaults()
      @bind_share_events()
      @load_embeds()
      @load_indeces()

    did_load: (@share) ->
      @bind_share_events()
      @run_callbacks("after_load")
      @load_embeds()
      @did_index()

    did_load_embedded: (@share) ->
      @needs_indexing = false

      @load_embeds()
      @bind_share_events()
      # FIXME, DON'T DO THIS BEFORE THE INDEX HAS LOADED!
      @set_attributes_from_share()
      @did_index()

    ensure_defaults: ->
      @share.at().set(@attributes_for_sharing()) unless @share.get()

      for name, config of @constructor.indeces
        index = @index(name)
        index.set(new Object) unless index.get()

    new: -> @share is undefined

    index: (index_name) ->
      @share.at("index:#{index_name}")

    indexer: (index_name) ->
      return (model) =>
        @index(index_name).at(model.id).set model.constructor._type, (error) ->
          AS.warn "FIXME: handle error in Model#indexer"
          model.did_index()

    when_indexed: (fn) ->
      if @needs_indexing
        @when_indexed_callbacks ?= []
        @when_indexed_callbacks.push(fn)
      else
        fn.call(this)

    did_index: ->
      @needs_indexing = false
      fn.call(this) for fn in @when_indexed_callbacks || []

    attributes_for_sharing: ->
      all = {id:@id, _type: @constructor._type}

      for name, config of @constructor.fields || {}
        if @attributes[name] is undefined
          all[name] = ""
        else
          all[name] = @attributes[name]

      for name, config of @constructor.has_manys || {}
        all[name] = @attributes[name].map((model) -> model.id).value()

      for name, config of @constructor.embeds_manys || {}
        value = @attributes[name].map((model) -> model.attributes_for_sharing()).value()
        continue unless value
        all[name] = value

      for name, config of @constructor.belongs_tos || {}
        continue if @attributes[name] is undefined
        all[name] = @attributes[name]

      for name, config of @constructor.has_ones || {}
        AS.warn "Model#attributes_for_sharing does not implement has_ones"

      for name, config of @constructor.embeds_ones || {}
        continue unless value = @[name]().attributes_for_sharing()
        all[name] = value

      return all

    set_attributes_from_share: ->
      for name, config of @constructor.fields || {}
        @attributes[name] = @share.at(name).get()

      for name, config of @constructor.has_manys || {}
        collection = @[name]()
        for data in @share.at(name).get() || []
          # clone here, or we have shared references which confuses sharejs
          data = AS.deep_clone(data)
          # We might have created this model ourselves.
          continue if collection.include(AS.All.byId[data]).value()
          collection.add(data, remote:true)

      for name, config of @constructor.belongs_tos || {}
        @attributes[name] = @share.at(name).get()

      for name, config of @constructor.has_ones || {}
        AS.warn "Model#attributes_for_sharing does not implement has_ones"

  #   #FIXME: implement as ParallelHashQueue
    load_indeces: ->
      count = _(@constructor.indeces || {}).keys().length
      loaded = 0

      @indeces_did_load() if count is loaded

      callback = =>
        loaded++
        @indeces_did_load() if count is loaded

      for name, config of @constructor.indeces
        @load_index(name, callback)

    #FIXME: implement as ParallelHashQueue
    load_index: (name, callback) ->
      index = @index(name).get() || {}
      count = _(index).keys().length
      loaded = 0
      callback() if count is loaded

      _callback = (share) =>
        @loaded_data[share.at("id").get()] = share
        loaded++
        callback() if count is loaded

      for id, _type of index
        model = AS.module(_type).load(id, _callback)
        model.bind "destroy", => @index(name).at(id).del()

    load_embeds: ->
      for name, config of @constructor.embeds_manys || {}
        collection = @[name]()
        for data, index in @share.at(name).get() || []
          model = AS.module(data._type).embedded(data.id, @share.at(name, index))
          collection.add(model, remote:true)

      for name, config of @constructor.embeds_ones || {}
        data = @share.at(name).get()
        model = AS.module(data._type).embedded(data.id, @share.at(name))
        @attributes[name] = model.id

    indeces_did_load: ->
      @needs_indexing = false
      @build_loaded_data()
      @set_attributes_from_share()

      for name, config of @constructor.indeces
        for id, _type of @index(name).get()
          AS.All.byId[id].indeces_did_load()

      @trigger("ready")

    build_loaded_data: ->
      for id, share of @loaded_data || {}
        AS.All.byId[id].did_load(share)

    share_binding: (path, event, callback) ->
      if path
        @share_bindings.push @share.at(path).on event, callback
      else
        @share_bindings.push @share.at().on event, callback

    embedded_binding: (@share) -> @bind_share_events()

    revoke_share_bindings: ->
      @share.removeListener(it) for it in @share_bindings
      @share_bindings = []
      @unbind_share_events()

    unbind_share_events: ->
      @unbind(@share_namespace)
      for name, config of @constructor.has_manys
        @[name]().unbind(@share_namespace)

      for name, config of @constructor.embeds_manys
        @[name]().each (model) =>
          model.unbind(@share_namespace)
          model.revoke_share_bindings()

      AS.warn "unbind_share_events does not unbind has_one/embeds_one"

    bind_share_events: ->
      @bind_field_sharing()
      @bind_has_many_sharing()
      @bind_belongs_to_sharing()
      @bind_has_one_sharing()
      @bind_embeds_many_sharing()
      @bind_embeds_one_sharing()
      @bind_indeces()

    bind_field_sharing: ->
      set_from_local = (model, field, value, options={}) =>
        return if options.remote is true
        model.when_indexed =>
          if _.isString(@share.at(field).get())
            length = @share.at(field).get().length
            @share.at(field).del(0, length)
            @share.at(field).insert(0, value)
          else
            @share.at(field).set(value)

      set_from_remote = (key, value, because) =>
        return unless @constructor.fields?[key]
        @[key]( @share.at(key).get(), remote: true) unless @share.at(key).get() is @[key]()

      @share_binding null, "insert", (key, value) -> set_from_remote(key, value, "null insert")
      @share_binding null, "replace", (key, previous, value) -> set_from_remote(key, value, "null replace")

      for name, config of @constructor.fields || {}
        do (name) =>
          @bind "change:#{name}#{@share_namespace}", set_from_local

          @share_binding name, "insert", (position, text) =>
            @trigger("share:insert:#{name}", position, text)
            set_from_remote name, @share.at(name).get(), "insert"

          @share_binding name, "delete", (position, text) =>
            @trigger("share:delete:#{name}", position, text)
            set_from_remote name, @share.at(name).get(), "delete"

    bind_has_many_sharing: ->
      for name, config of @constructor.has_manys
        do (name) =>
          collection = @[name]()

          add_handler = (model, collection, options={}) =>
            return if options.remote is true
            model.when_indexed =>
              @share.at(name).insert(options.at, id:model.id, _type: model.constructor._type)

          collection.bind "add#{@share_namespace}", add_handler, this

          remove_handler = (model, collection, options={}) =>
            return if options.remote is true
            model.when_indexed => @share.at(name, options.at).remove()

          collection.bind "remove#{@share_namespace}", remove_handler, this

          @share_binding name, "insert", (position, data) =>
            collection.add data, at: position, remote: true

          @share_binding name, "delete", (position, data) =>
            collection.remove AS.All.byId[data.id], remote: true

    bind_embeds_many_sharing: ->
      for name, config of @constructor.embeds_manys
        do (name) =>
          collection = @[name]()

          # collection.each (model, index) =>
          #   model.embedded_binding(@share.at(name, index))

          add_handler = (model, collection, options={}) =>
            model.did_index()# if options.remote is true# embedded models don't index
            if options.remote isnt true
              @share.at(name).insert(options.at, model.attributes_for_sharing())
            if model.share is undefined
              model.embedded_binding(@share.at(name, collection.indexOf(model).value()))

          collection.bind "add#{@share_namespace}", add_handler, this

          remove_handler = (model, collection, options={}) =>
            model.revoke_share_bindings()
            return if options.remote is true
            @share.at(name).at(options.at).remove()

          collection.bind "remove#{@share_namespace}", remove_handler, this

          @share_binding name, "insert", (position, data) =>
            collection.add data, at: position, remote: true

          @share_binding name, "delete", (position, data) =>
            collection.remove AS.All.byId[data.id], remote: true

    bind_belongs_to_sharing: ->
      set_from_local = (model, field, value, options={}) =>
        value = null if value is undefined
        model.when_indexed =>
          @share.at(field).set(value) unless options.remote

      for name, config of @constructor.belongs_tos || {}
        @bind "change:#{name}#{@share_namespace}", set_from_local, this

      set_from_remote = (key, value) =>
        @[key](value, remote: true) if @constructor.belongs_tos?[key]

      @share_binding null, "insert", (key, value) -> set_from_remote(key, value)
      @share_binding null, "replace", (key, previous, value) -> set_from_remote(key, value)

    bind_has_one_sharing: ->
      AS.warn "Model#bind_has_one_sharing not implemented"

    bind_embeds_one_sharing: ->
      for name, config of @constructor.embeds_ones
        do (name) =>
          @[name]().embedded_binding(@share.at(name))

          change_handler = (key, value, options={}) =>
            return if options.remote is true
            value = @[name]()
            if value?.attributes_for_sharing
              @share.at(name).set(value.attributes_for_sharing())
              value.embedded_binding(@share.at(name))
            else
              @share.at(name).set(null)

          set_from_remote = (key, value) =>
            @[key](value, remote: true) if @constructor.embeds_ones?[key]

          @bind "change:#{name}#{@share_namespace}", change_handler, this
          @share_binding null, "replace", (key, previous, value) -> set_from_remote(key, value)

    bind_indeces: ->
      for index, config of @constructor.indeces || {}
        @share_binding "index:#{index}", "insert", (id, konstructor) =>
          loaded = AS.module(konstructor).load id, (share) ->
            @did_load(share)
            @indeces_did_load()
          @trigger("indexload", loaded)
