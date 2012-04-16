helper = require require("path").resolve("./test/helper")
{NS, AS, _, sinon, makeDoc, coreSetUp, RelationModel, FieldModel} = helper
exports.setUp = coreSetUp

Model = NS.Model = AS.Model.extend()
Model.field "name"
Model.field "band", default: "the Tijuana Brass"
Model.field "number", type: Number
Model.field "boolean", type: Boolean
Model.field "enum", type: AS.Enum, values: ["zero", "one", "two"]
Model.property "other"

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

  "Enum":
    "reads enums": (test) ->
      o = Model.new()
      o.enum.value = 0
      test.equal o.enum.get(), "zero"
      test.done()

    "writes enums": (test) ->
      o = Model.new()
      o.enum.set("two")
      test.equal 2, o.enum.value
      test.done()

  "bindPath": 
    "may be used in path bindings": (test) ->
      o = Model.new()
      o.bindPath ['boolean'], -> test.done()
      o.boolean.set(true)

    "may be nested in path bindings": (test) ->
      other = Model.new()
      o = Model.new(other:other)
      o.bindPath ['other', 'boolean'], -> test.done()
      other.boolean.set(true)

  "Sharing":
    "propagate share value to model on sync": (test) ->
      o = Model.new()
      share = makeDoc()
      share.at().set name: "from share"
      o.name.syncWith(share)
      test.equal "from share", o.name.get()
      test.done()
 
    "propagate field value to @share on sync": (test) ->
      o = Model.new(name: "from model")
      share = makeDoc()
      share.at().set {}
      o.name.syncWith(share)
      test.equal "from model", share.at('name').get()
      test.done()

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