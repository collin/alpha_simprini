helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp


NS.Virtualized = AS.Model.extend ->
  @field "name"
  @virtualProperties "name",
    virtualA: ->
    virtualB: ->

exports.VirtualProperty =
  "is a virtual": (test) ->
    test.ok NS.Virtualized.properties.virtualA instanceof AS.Model.VirtualProperty
    test.ok NS.Virtualized.properties.virtualB instanceof AS.Model.VirtualProperty    
    test.done()