helper = require require("path").resolve("./test/helper")
{NS, AS, _, sinon, makeDoc, coreSetUp, RelationModel, FieldModel} = helper
exports.setUp = coreSetUp

Model = NS.Model = AS.Model.extend()
Model.field "name"
Model.field "band", default: "the Tijuana Brass"
Model.field "number", type: Number
Model.field "boolean", type: Boolean

exports.Field =
  "is a property": (test) ->
    o = Model.new()
    test.equal "AlphaSimprini.Model.Field.Instance", o.name.constructor.path()
    test.done()

  "is set when constructing a model": (test) ->
    o = Model.new name: "Herb Alpert"
    test.equal "Herb Alpert", o.name.get()
    test.done()

  "may specify a default value for a field": (test) ->
    o = Model.new()
    test.equal "the Tijuana Brass", o.band.get()
    test.done()

  "default type is String": (test) ->
    test.equal Model.properties.name.options.type, String
    test.done()

  "number fields are cast as numbers": (test) ->
    o = Model.new( number: "44.89" )
    test.equal 44.89, o.number.get()
    o.number.set "44"
    test.equal 44, o.number.get()
    test.done()

  "boolean fields are cast as booleans": (test) ->
    o = Model.new( boolean: "true" )
    test.equal true, o.boolean.get()
    o.boolean.set "false"
    test.equal false, o.boolean.get()
    test.done()

  "change event triggers on model and field": (test) ->
    test.expect 4
    o = Model.new()
    o.bind "change", -> test.ok true
    o.bind "change:boolean", -> test.ok true
    o.boolean.bind "change", -> test.ok true
    o.boolean.set(true)
    o.number.set 43
    test.done()

  "Sharing":
    setUp: (callback) ->
      @o = Model.new()
      @share = makeDoc()
      @share.at().set {}
      @o.name.syncWith(@share)
      callback()

    "field updates when share is set": (test) ->
      @share.emit "remoteop", @share.at('name').set("SET VALUE")
      test.equal "SET VALUE", @o.name.get()
      test.done()

    "share updates when field is set": (test) ->
      @o.name.set("NOTIFIED")
      test.equal "NOTIFIED", @share.at('name').get()
      test.done()

    "field updates on share insert": (test) ->
      @o.name.set("abc")
      @share.emit "remoteop", @share.at('name').insert(0, "123")
      test.equal "123abc", @o.name.get()
      test.done()

    "field updates on share delete": (test) ->
      @o.name.set("Co123llin")
      @share.emit "remoteop", @share.at('name').del(2, 3)
      test.equal "Collin", @o.name.get()
      test.done()