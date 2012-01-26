AS = require("alpha_simprini")
_ = require("underscore")
AS.All =
  byId: {}
  byCid: {}

require_config = (config, key, message) ->
  return if key in config
  throw new Error message

FieldTypes =
  "Boolean":
    read: (value) ->
      return value if _.isBoolean(value)
      return true if value is "true"
      return false if value is "false"
      return false

    write: (value) ->
      return "true" if value is "true" or value is true
      return "false" if value is "false" or value is false
      return "false"

  "String":
    read: (value) -> value
    write: (value) -> value

  "Number":
    read: (value) -> value
    write: (value) -> value

class AS.Model
  AS.Event.extends(this)
  AS.InheritableAttrs.extends(this)
  AS.Callbacks.extends(this)

  @define_callbacks(after: ["initialize"], before: ["initialize"])

  @embeds_many: (name, config={}) ->
    config.relation = true
    @relation(name)
    @attribute(name)
    @write_inheritable_value("embeds_manys", name, config)

  @has_many: (name, config={}) ->
    config.relation = true
    @relation(name)
    @attribute(name)
    @write_inheritable_value("has_manys", name, config)

  @embeds_one: (name, config={}) ->
    # require_config config, 'model', "for @embeds_one '#{name}, must specify the 'model' option. (Provide a function that returns a model constructor.)"

    config.relation = true
    @relation(name)
    @write_inheritable_value("embeds_ones", name, config)

    @::[name] = (value) ->
      unless value is undefined
        if value is null
          @set_attribute(name, undefined)
        else if value.cid
          @set_attribute(name, value.cid)
        else if _.isString(value)
          @set_attribute(name, value)
        else
          if value._type
            model = AS.module(value._type)
          else
            model = AS.Model
          @set_attribute name, (new model value).cid

      # attach our self to the embedded model for reflection, k?
      # Laffo, this could get ugly, except, we'll never be embedded in more than one
      # place at the same  time, so I think we'll survive.
      # still, a half-baked idea.
      embedded = AS.All.byCid[@get_attribute(name)]
      embedded?.embedded_in ?= this
      # We always want to return the embedded object
      embedded

  @has_one: (name, config={}) ->
    config.relation = true
    @relation(name)
    @write_inheritable_value("has_ones", name, config)

    @::[name] = (value) ->
      if value is undefined
        AS.All.byCid[@get_attribute(name)]
      else
        if value is null
          @set_attribute(name, undefined)
        else if value.cid
          @set_attribute(name, value.cid)
        else if _.isString(value)
          @set_attribute(name, value)
        else
          if value._type
            model = AS.module(value._type)
          else
            model = AS.Model
          @set_attribute name, (new model value).cid

  @belongs_to: (name, config={}) ->
    config.relation = true
    @relation(name)
    @write_inheritable_value("belongs_tos", name, config)

    @::[name] = (value) ->
      if value is undefined
        AS.All.byCid[@get_attribute(name)]
      else
        if value is null
          @set_attribute(name, undefined)
        else if value.cid
          @set_attribute(name, value.cid)
        else if _.isString(value)
          @set_attribute(name, value)
        else
          throw new Error(["Cannot set #{name} to unexpected value. Try passing a cid, or an object with a cid. Value was: ", value])

  @relation: (name) ->
    @push_inheritable_item("relations", name)

  @field: (name, config={}) ->
    if config.type?.name
      config.type = FieldTypes[config.type.name]

    config.type ?= FieldTypes.String
    @write_inheritable_value("fields", name, config)
    @attribute(name, config)

  @virtual_properties: (fields..., defs) ->
    virtual_cache = {}
    for name, fn of defs
      @write_inheritable_value("virtuals", name, fields)

    # bind to all events for fields
    @after_initialize (model) ->
      for field in fields
        if model.constructor.fields?[field] or model.constructor.embeds_ones?[field]
          model.bind "change:#{field}", (name, value, options) ->
            for name, fn of defs
              _value = model[name]()
              continue if _value is virtual_cache[name]
              virtual_cache[field] = _value
              model.trigger("change", name, _value, options)
              model.trigger("change:#{name}", name, _value, options)

        else if model.constructor.has_manys?[field] or model.constructor.embeds_manys?[field]
          relation = model[field]()

          callback = (collection, item, options) ->
            for name, fn of defs
              _value = model[name]()
              continue if _value is virtual_cache[name]
              virtual_cache[name] = _value
              model.trigger("change", name, _value, options)
              model.trigger("change:#{name}", name, _value, options)

          relation.bind "add", callback
          relation.bind "remove", callback
          relation.bind "change", callback

    # set up functions to reat virtual properties
    for name, fn of defs
      @::[name] = fn

  @attribute: (name, config={}) ->
    if config.type
      @::[name] = (value, options) ->
        if value is undefined
          config.type.read @get_attribute(name)
        else
          @set_attribute name, config.type.write(value), options
    else
      @::[name] = (value, options) ->
        if value is undefined
          @get_attribute(name)
        else
          @set_attribute(name, value, options)

  @initialize_relations: (model)  ->

  constructor: (@attributes = {}, options={}) ->
    # @model is @, used for compatibility with wrappers like ViewModel
    @model = this
    @run_callbacks "before_initialize"
    @set_defaults() if @new()
    @initialize(options)
    @run_callbacks "after_initialize"

  initialize: (options={}) ->
    @attributes.id ?= AS.uniq()

    @id = @attributes.id
    @cid = @id or _.uniqueId("c")

    AS.All.byCid[@cid] = AS.All.byId[@id] = this

    @initialize_embeds_many(name, config) for name, config of @constructor.embeds_manys || {}
    @initialize_has_many(name, config) for name, config of @constructor.has_manys || {}
    @initialize_embeds_one(name, config) for name, config of @constructor.embeds_ones || {}
    @initialize_has_one(name, config) for name, config of @constructor.has_ones || {}
    @initialize_belongs_to(name, config) for name, config of @constructor.belongs_tos || {}

    # @persisted()

  new: -> @attributes.id is undefined

  set_defaults: () ->
    for name, config of @constructor.fields || {}
      @[name]() or @[name](config.default)

  read_path: (path) ->
    target = this
    for piece in path
      target = target[piece]()
    target

  write_path: (path, value) ->
    target = this
    for piece in path[..-2]
      target = target[piece]()
    target[path[path.length - 1]](value)

  last: (attr) ->
    [@attributes, @previous_attributes] = [@previous_attributes, @attributes]
    last = @[attr]()
    [@attributes, @previous_attributes] = [@previous_attributes, @attributes]
    last

  initialize_embeds_many: (name, config) ->
    data = {}
    klass = class this["#{name}_collection_klass"] extends AS.EmbeddedCollection
    _.extend klass::, config
    klass.model = -> config.model() if config.model
    collection = data[name] = new klass(@[name]?())
    collection.source = this
    @set data

  initialize_has_many: (name, config) ->
    @has_manys ?= {}
    data = {}
    klass = class this["#{name}_collection_klass"] extends AS.Collection
    _.extend klass::, config
    klass.model = -> config.model?() or AS.Model
    @has_manys[name] = collection = data[name] = new klass()
    collection.source = this
    @set data

  initialize_embeds_one: (name, config) ->
    unless @[name](@attributes[name])
      @[name]( new (config.model?() || AS.Model) ) unless config.prefill is false

  initialize_has_one: (name, config) ->
    @[name](@attributes[name])

  initialize_belongs_to: (name, config) ->
    # pass; not sure you have to do anything, this should be properly set already.

  save: () ->
    return false unless @changed()
    @persisted()
    true

  # Persisted is a callback here.
  # Actual persistance will be handled by an observer. DEAL WITH IT IF YOU WANT IT.
  persisted: ->
    @previous_attributes = AS.deep_clone(@attributes)

  changes: () ->
    changed = {}
    for key, value of @attributes
      changed[key] = value unless @previous_attributes[value] is value
    changed

  changed: () -> _(@changes()).chain().keys().any().value()

  get: (attr) -> @[attr]()

  set: (attrs) ->
    @[key](value) for key, value of attrs

  set_attribute: (name, value, options={}) ->
    @attributes[name] = value
    @trigger("change:#{name}", name, value, options)
    @trigger("change", name, value, options)
    value

  get_attribute: (name) ->
    @attributes?[name]

  destroy: () ->
    @trigger("destroy")

  trigger: () ->
    args =  [].concat.apply [], arguments
    args.splice 1, 0, this
    AS.Event.instance_methods.trigger.apply this, args


