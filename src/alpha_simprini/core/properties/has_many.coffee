{include, any, each, clone} = _
_include = include

class AS.Model.HasMany < AS.Model.Field
  def couldBe: (test) ->
    return true if @options.model?() in (test.ancestors or [])
    @_super.apply(this, arguments)

class AS.Model.HasMany.Instance < AS.Model.Field.Instance
  delegate AS.COLLECTION_DELEGATES, to: "backingCollection"
  delegate 'groupBy', 'bind', 'trigger', 'unbind',
            'prev', 'next', 'before', 'after', to: "backingCollection"

  def inspect: ->
    "#{@options.name}: [#{@backingCollection.length}]}"
  # @::inspect.doc =
  #   return: String
  #   desc: """
  #
  #   """

  def initialize: (@object, @options={}) ->
    @model = @options.model
    @options.source = @object if @options.inverse
    @backingCollection = AS.Collection.new(undefined, @options)

    @backingCollection.bind "remove", (model) =>
      @triggerDependants()

    @bind('change', (=> @triggerDependants()), this)
    if @options.dependant is "destroy"
      @object.bind "destroy", => @backingCollection.invoke("destroy")
  # @::initialize.doc =
  #   params: [
  #     ["@object", AS.Model, true]
  #     ["@options", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def syncWith: (share) ->
    return if @options.remote is false
    @share = share.at(@options.name)
    @stopSync()

    @synapse = @constructor.Synapse.new(this)
    @shareSynapse = @constructor.ShareSynapse.new(share, @options.name)

    alreadyThere = clone @backingCollection.models.value()

    if fromShare = @share.get()
      for item in fromShare 
        # continue if added from an inverse relationship
        continue if @backingCollection.include(item).value()
        @add(item)

    if any(alreadyThere)
      @synapse.block =>
        each alreadyThere, (item) => 
          @shareSynapse.insert(item, {})

    # Stick this on the RunLoop so we don't get double insertion errors
    Taxi.Governer.react this, =>
      @synapse.notify(@shareSynapse)
  # @::syncWith.doc =
  #   params: [
  #     ["share", "ShareJS.Doc", true]
  #   ]
  #   desc: """
  #
  #   """

  def objects: (test) ->
    if _.include test?.ancestors, AS.Model
      model for model in @backingCollection.models.value() when model instanceof test
    else
      @backingCollection.models.value()
  # @::objects.doc =
  #   return: [AS.Model]
  #   desc: """
  #
  #   """

  def bindToPathSegment: (segment) ->
    segment.binds this, "add", segment.insertCallback
    segment.binds this, "remove", segment.removeCallback
    segment.binds this, "change", segment.changeCallback
  # @::bindToPathSegment.doc =
  #   params: [
  #     ["segment", Taxi.Segment, true]
  #   ]
  #   desc: """
  #
  #   """

  def get: -> this
  # @::get.doc = 
  #   desc: """
  #     Returns self.
  #   """

  def readPath: (path) ->
    head = path[0]
    tail = path[1..]
    
    target = if head instanceof Number
      @at(head)
    else if _include(head.ancestors, AS.Model)
      @find( (item) -> _include(item.constructor.ancestors, head) ).value()
    else
      @find( (item) -> item is head ).value()

    return unless target

    if any tail
      target.readPath(tail)
    else
      return target

  def writePath: (path, value) ->
    head = path[0]
    tail = path[1..]

    target = if head instanceof Number
      @at(head)
    else if _include(head.ancestors, AS.Model)
      @find( (item) -> _include(item.constructor.ancestors, head)).value()
    else
      @find( (item) -> item is head ).value()

    return unless target

    if tail[1]
      target.writePath(tail, value)
    else
      head[tail[0]].set(value)
    

  def set: (models) ->
    @backingCollection.add(model) for model in models
  # @::set.doc =
  #   params: [
  #     ["models", [[AS.Model, String, Object]], true]
  #   ]
  #   desc: """
  #
  #   """

  def add: (model, options) ->
    added = @backingCollection.add(model, options)
    @triggerDependants()
    return added
  # @::add.doc =
  #   params: [
  #     ["model", AS.Model, true]
  #     ["options", Object, false]
  #   ]
  #   desc: """
  #
  #   """

  def at: (index) -> @backingCollection.at.apply(@backingCollection, arguments)
  # @::at.doc =
  #   params: [
  #     ["index", Number, true]
  #   ]
  #   return: [AS.Model, undefined]
  #   desc: """
  #
  #   """

  def remove: (model) ->
    # triggerDependants is called when the backing collection fires the remove event.
    # because object removal can be triggered by object destruction.
    removed = @backingCollection.remove.apply(@backingCollection, arguments)
    return removed
  # @::remove.doc =
  #   params: [
  #     ["model", AS.Model, true]
  #   ]
  #   return: AS.Model
  #   desc: """
  #
  #   """

  def pluck: (key) ->
    @map (item) -> item[key].get()
  # @::pluck.doc =
  #   params: [
  #     ["key", String, true]
  #   ]
  #   return: ["*"]
  #   desc: """
  #
  #   """

  def any: ->
    @count() > 0
  # @::any.doc =
  #   return: "Boolean"
  #   desc: """
  #     Returns true if there are 1 or more items in the collection.
  #   """

  def count: ->
    @backingCollection.length
  # @::count.doc = 
  #   return: "Number"
  #   desc: """
  #     Returns the number of items in the collection.
  #   """
    

class AS.Model.HasMany.Instance.Synapse < AS.Model.Field.Instance.Synapse
  def rawValue: -> @backingCollection.pluck('id').value()

  def insert: (item, options) ->
    @raw.add(item, options)

  def remove: (item, options) ->
    @raw.remove @raw.at(options.at)

  def binds: (insertCallback, removeCallback) ->
    @raw.bind "add#{@namespace}", (model, collection, options) ->
      insertCallback(model, options)

    @raw.bind "remove#{@namespace}", (model, collection, options) ->
      removeCallback(model, options)

  def each: (fn) -> @raw.each(fn)

  def unbinds: ->
    @raw.unbind(@namespace)

class AS.Model.Field.Instance.ShareSynapse < AS.Model.Field.Instance.ShareSynapse
  def initialize: (@raw, @path...) ->
    @_super.apply(this, arguments)

  def binds: (insertCallback, removeCallback) ->
    raw = @raw.at(@path)
    @listeners = [
      # raw.on "insert", (position, data) -> insertCallback(data, at: position)
      # raw.on "delete", (position, data) -> removeCallback(data, at: position)
    ]

  def unbinds: ->
    @raw.removeListener(listener) for listener in @listeners

  def insert: (model, options) ->
    @raw.at(@path).set([]) if @raw.at(@path).get() in [null, undefined]

    options.at ?= @raw.at(@path).get().length
    if model.id in @raw.at(@path).get()
      AS.warn "Attempted to add", model, "(again) to share at path:", @path
      return
    @raw.at(@path).insert(options.at, model.id)

  def remove: (model, options) ->
    @raw.at(@path.concat([options.at])).remove()
    @raw.at(@path).remove() unless any @raw.at(@path).get()

  def each: (fn) ->
    _.each @raw.at(@path).get(), fn

#FIXME: this should have worked
# AS.Model.HasMany.Instance.delegate "add", "remove", "bind", "unbind", "trigger", to: "backingCollection"

AS.Model.defs hasMany: (name, options) ->
  AS.Model.HasMany.new(name, this, options)
  definition = {}
  definition["#{name}Count"] = -> @[name].count()
  @virtualProperties name, definition
    

