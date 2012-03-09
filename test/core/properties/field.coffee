helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel} = helper
exports.setUp = coreSetUp

Model = AS.Model.extend()
Model.field "name"
Model.field "band", default: "the Tijuana Brass"
Model.field "number", type: Number
Model.field "boolean", type: Boolean

exports.Field =
  "is a property": (test) ->
    o = Model.create()
    test.equal "AlphaSimprini.Model.Field.Instance", o.name.constructor.path()
    test.done()

  "is set when constructing a model": (test) ->
    o = Model.create name: "Herb Alpert"
    test.equal "Herb Alpert", o.name.get()
    test.done()

  "may specify a default value for a field": (test) ->
    o = Model.create()
    test.equal "the Tijuana Brass", o.band.get()
    test.done()

  "default type is String": (test) ->
    test.equal Model.properties.name.options.type, String
    test.done()

  "number fields are cast as numbers": (test) ->
    o = Model.create( number: "44.89" )
    test.equal 44.89, o.number.get()
    o.number.set "44"
    test.equal 44, o.number.get()
    test.done()

  "boolean fields are cast as booleans": (test) ->
    o = Model.create( boolean: "true" )
    test.equal true, o.boolean.get()
    o.boolean.set "false"
    test.equal false, o.boolean.get()
    test.done()

  "change event triggers on model and field": (test) ->
    test.expect 4
    o = Model.create()
    o.bind "change", -> test.ok true
    o.bind "change:boolean", -> test.ok true
    o.boolean.bind "change", -> test.ok true
    o.boolean.set(true)
    o.number.set 43
    test.done()
