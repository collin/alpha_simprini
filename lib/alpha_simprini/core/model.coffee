AS = require("alpha_simprini")
{uniqueId, toArray} = _ = require("underscore")
Taxi = require("taxi")

AS.All = byCid: {}, byId: {}, byIdRef: {}

AS.Model = AS.Object.extend ({def, include}) ->
  include Taxi.Mixin

  def initialize: (attributes={}) ->
    @model = this
    @id = attributes.id ? AS.uniq()
    @idRef = "#{@id}-#{@constructor.path()}"
    @cid = @idRef or uniqueId("c")
    delete attributes.id

    AS.All.byCid[@cid] = AS.All.byId[@id] = AS.All.byIdRef[@idRef] = this

    @set(attributes)

  def set: (attributes) ->    
    for key, value of attributes
      # assert @[key].set
      @[key].set(value) 

  def destroy: ->
    @trigger("destroy")

  def trigger: ->
    args = toArray(arguments)
    args.splice(1, 0, this)
    @_super.apply this, args


