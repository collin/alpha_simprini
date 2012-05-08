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

  defs find: (id) ->
    idRef = makeIdRef(id, this)
    AS.All.byIdRef[idRef] or @new(id:id)
  # @find.doc =
  #   params: [
  #     ["id", String, true]
  #   ]
  #   return: AS.Model
  #   desc: """
  #     If a model exsist by the `id` it is retrieved from an identity map.
  #     Otherwise a model is created with `id`.
  #   """

  def initialize: (attributes={}) ->
    attributes.id ?= AS.uniq()
    @model = this
    if id = attributes.id
      delete attributes.id
      @setId(id)
    @set(attributes)
    @runCallbacks 'afterInitialize'
  # @::initialize.doc =
  #   params: [
  #     ["attributes", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def properties: ->
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
