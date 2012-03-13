AS = require("alpha_simprini")
{uniqueId, toArray} = _ = require("underscore")
Taxi = require("taxi")

AS.Model = AS.Object.extend ({def, include}) ->
  include Taxi.Mixin

  def initialize: (attributes={}) ->
    @model = this
    @id = attributes.id ? AS.uniq()
    @cid = @id or uniqueId("c")
    delete attributes.id

    AS.All.byCid[@cid] = AS.All.byId[@id] = this

    @[key].set(value) for key, value of attributes

  def trigger: ->
    args = toArray(arguments)
    args.splice(1, 0, this)
    @_super.apply this, args


