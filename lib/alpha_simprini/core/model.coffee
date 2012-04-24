AS = require("alpha_simprini")
{uniqueId, toArray} = _ = require("underscore")
Taxi = require("taxi")

AS.All = byCid: {}, byId: {}, byIdRef: {}

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
    AS.All.byId[id] or @new(id:id)

  def initialize: (attributes={}) ->
    @model = this
    if id = attributes.id
      delete attributes.id
      @setId(id)
    else if !@id
      @setId(AS.uniq())
    @set(attributes)
    @runCallbacks 'afterInitialize'

  def set: (attributes) ->    
    for key, value of attributes
      continue if key is "_type"
      if key is "id"
        @setId(value)
      else
        property = @[key]
        @[key].set(value) 

  def setId: (id) ->
    if @id
      delete AS.All.byId[@id]
      delete AS.All.byIdRef["#{@id}-#{@constructor.path()}"]
    
    @id = id
    @idRef = "#{@id}-#{@constructor.path()}"

    # NEVER CHANGE THE CID
    @cid ?= @idRef or uniqueId("c")

    AS.All.byCid[@cid] = AS.All.byId[@id] = AS.All.byIdRef[@idRef] = this

    # Don't trigger 'change', this must be specifically listened for.
    @trigger("change:id")

  def destroy: ->
    @trigger("destroy")

  def trigger: ->
    args = toArray(arguments)
    args.splice(1, 0, this)
    @_super.apply this, args


