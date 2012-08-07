{uniqueId, toArray, keys} = _

AS.All = byCid: {}, byId: {}, byIdRef: {}

makeIdRef = (id, constructor) -> "#{id}-#{constructor.path()}"

AS.Model = AS.Object.extend ({delegate, include, def, defs}) ->
  include Taxi.Mixin
  include AS.Callbacks

  @defineCallbacks
    # before: [
    #   'initialize'
    # ]
    after: [
      'initialize'
    ]

  defs find: (id, options) ->
    idRef = makeIdRef(id, this)
    AS.All.byIdRef[idRef] or @new(id:id, options)
  # @find.doc =
  #   params: [
  #     ["id", String, true]
  #   ]
  #   return: AS.Model
  #   desc: """
  #     If a model exsist by the `id` it is retrieved from an identity map.
  #     Otherwise a model is created with `id`.
  #   """

  def initialize: (attributes={}, options={}) ->
    attributes.id ?= AS.uniq()
    @model = this
    if id = attributes.id
      delete attributes.id
      @setId(id)
    @set(attributes)
    @runCallbacks 'afterInitialize' unless options.skipCallbacks is true
  # @::initialize.doc =
  #   params: [
  #     ["attributes", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """
  
  defs prepare: (attributes) ->
    @new(attributes, {skipCallbacks: true})
  # @prepare.doc = 
  #   params: [
  #     ["id", String, true, tag:"id for a new model"]
  #   ]
  #   desc: """
  #     Creates a new model of this class without running callbacks.
  #   """

  def takeOver: (model) ->
    for property in model.properties()
      continue unless property.rawValue?
      name = property.options.name
      console.log "takeOver #{name} #{property.rawValue()}"
      @[name].set property.rawValue()
    @runCallbacks 'afterInitialize'
  # @::takeOver.doc = 
  #   params: [
  #     []
  #   ]
  #   desc: """
  #     Take on the properties of another model. Used when cutting
  #     over to a new code base.
  #   """
  
  def payload: ->
    payload = {}

    for property in @properties()
      continue unless property instanceof AS.Model.Field.Instance
      name = property.options.name
      switch property.constructor
        when AS.Model.Field.Instance
          [key, value] = [name, property.value or property.options.default]
        when AS.Model.BelongsTo.Instance, AS.Model.HasOne.Instance
          [key, value] = ["#{name}", property.get()?.id or null]
        when AS.Model.HasMany.Instance
          [key, value] = ["#{name}", property.map((model) -> model.id).value()]

      payload[key] = if value? then value else null

    return payload
  # @::payload.doc = 
  #   params: [
  #     []
  #   ]
  #   desc: """
  #     
  #   """

  def properties: ->
    return [] unless @constructor.properties?
    @[name] for name in keys(@constructor.properties)
  # @::properties.doc =
  #   desc: """
  #   """

  def set: (attributes) ->
    for key, value of attributes
      continue if key is "_type"
      if key is "id"
        @setId(value)
      else
        property = @[key]
        @[key]?.set(value)
  # @::set.doc =
  #   params: [
  #     ["attributes", Object, true]
  #   ]
  #   desc: """
  #   """

  def setId: (id) ->
    if @id
      delete AS.All.byId[@id]
      delete AS.All.byIdRef["#{@id}-#{@constructor.path()}"]

    @id = id
    @idRef = makeIdRef(@id, @constructor)

    # NEVER CHANGE THE CID
    @cid ?= @idRef or uniqueId("c")

    AS.All.byCid[@cid] = AS.All.byId[@id] = AS.All.byIdRef[@idRef] = this

    # Don't trigger 'change', this must be specifically listened for.
    @trigger("change:id")
  # @::setId.doc =
  #   params: [
  #     ["id", String, true]
  #   ]
  #   desc: """
  #   """

  def destroy: ->
    @trigger("destroy")
  # @::destroy.doc =
  #   desc: """
  #   """

  def trigger: ->
    args = toArray(arguments)
    args.splice(1, 0, this)
    @_super.apply this, args
  # @::trigger.doc =
  #   params: [
  #     ["event", String, true]
  #     ["..."]
  #   ]
  #   desc: """
  #   """

  def readPath: (path) ->
    if path[1]
      this[path[0]].get().model?.readPath(path[1..])
    else if path[0]
      this[path[0]].get()
  # @::readPath.doc = 
  #   params: [
  #     []
  #   ]
  #   desc: """
  #     
  #   """

  def writePath: (path, value) ->
    target = this
    for piece in path[..-2]
      target = target[piece].get()
    target[path[path.length - 1]].set(value)
  # @::writePath.doc = 
  #   params: [
  #     []
  #   ]
  #   desc: """
  #     
  #   """

AS.Model.UniqueId = AS.Module.extend ({delegate, include, def, defs}) ->
  defs find: (id) ->
    AS.All.byId[id] or @new(id:id)
