AS = require("alpha_simprini")
{uniqueId, toArray} = _ = require("underscore")
Taxi = require("taxi")

AS.All = byCid: {}, byId: {}, byIdRef: {}

AS.Model = AS.Object.extend ({def, include}) ->
  include Taxi.Mixin

  def initialize: (attributes={}) ->
    @model = this
    if id = attributes.id
      delete attributes.id
      @setId(id)
    else if !@id
      @setId(AS.uniq())
    @set(attributes)

  def set: (attributes) ->    
    for key, value of attributes
      if key is "id"
        @setId(value)
      else
        # assert @[key].set
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


