{AS, NS, _, sinon, coreSetUp, makeDoc} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

AS.part("Core").require("model/rest")

Rested = NS.Rested = AS.Model.extend ({delegate, include, def, defs}) ->
  include AS.Model.REST
  @field "field"
  @field "thingId"
  @field "thingType"
  @hasMany "relations", model: -> SimpleRest
  # @hasOne "relation"
  @belongsTo "owner", model: -> SimpleRest

SimpleRest = NS.SimpleRest = AS.Model.extend ({delegate, include, def, defs}) ->
  include AS.Model.REST
  @field "field"
  @hasMany "relations", model: -> SimplerRest
  # @hasOne "relation"
  @belongsTo "owner", model: -> SimplerRest

SimplerRest = NS.SimplerRest = AS.Model.extend ({delegate, include, def, defs}) ->
  include AS.Model.REST
  @field "field"

plain =
  rested:
    id: 1
    field: "value"
    relation_ids: []
    owner_id: null
    thing_id: 1
    thing_type: "Thing"

sideLoading =
  rested:
    id: 1
    field: "packed"
    relation_ids: [1,2,3,4,5]
    owner_id: 1

  simple_rests: [
    {id: 1, field: "first", relation_ids: [2,4]}
    {id: 2, field: "second", relation_ids: []}
    {id: 3, field: "third", relation_ids: [1,2,3]}
    {id: 4, field: "fourth", relation_ids: [4,5]}
    {id: 5, field: "fifth", relation_ids: []}
  ]

  simpler_rests: [
    {id: 1, field: "first"}
    {id: 2, field: "second"}
    {id: 3, field: "third"}
    {id: 4, field: "fourth"}
    {id: 5, field: "fifth"}
  ]

module "REST"
test "loads a model from a simple JSON response", ->
  model = Rested.new()
  model.loadData(plain)
  equal "value", model.field.get()
  equal null, model.owner.get()
  equal 0, model.relations.backingCollection.length
  equal "1", model.thingId.get()
  equal "Thing", model.thingType.get()
  
test "loads a model from a JSON respons w/sideLoading", ->
  model = Rested.new()
  model.loadData(sideLoading)
  equal "packed", model.field.get()
  ok sideloaded = AS.All.byIdRef["1-NS.SimpleRest"]
  equal "first", sideloaded.field.get()
  equal AS.All.byIdRef["1-NS.SimpleRest"], model.owner.get()
  equal 5, model.relations.backingCollection.length
  