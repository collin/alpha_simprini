{makeDoc} = NS

F = Pathology.Namespace.new("Field")

Model = F.Model = AS.Model.extend()
Model.field "name"
Model.field "band", default: "the Tijuana Brass"
Model.field "number", type: Number
Model.field "boolean", type: Boolean
Model.field "enum", type: AS.Enum, values: ["zero", "one", "two"]
Model.property "other"

module "Field"
test "is a property", ->
  o = Model.new()
  equal "AlphaSimprini.Model.Field.Instance", o.name.constructor.path()

test "is set when constructing a model", ->
  o = Model.new name: "Herb Alpert"
  equal "Herb Alpert", o.name.get()

test "may specify a default value for a field", ->
  o = Model.new()
  equal "the Tijuana Brass", o.band.get()

test "default type is String", ->
  equal Model.properties.name.options.type, String

test "number fields are cast as numbers", ->
  o = Model.new( number: "44.89" )
  equal 44.89, o.number.get()
  o.number.set "44"
  equal 44, o.number.get()

test "boolean fields are cast as booleans", ->
  o = Model.new( boolean: "true" )
  equal true, o.boolean.get()
  o.boolean.set "false"
  equal false, o.boolean.get()

test "change event triggers on model and field", ->
  expect 4
  o = Model.new()
  o.bind "change", -> ok true
  o.bind "change:boolean", -> ok true
  o.boolean.bind "change", -> ok true
  o.boolean.set(true)
  o.number.set 43

module "Field.Enum"
test "reads enums", ->
  o = Model.new()
  o.enum.value = 0
  equal o.enum.get(), "zero"

test "writes enums", ->
  o = Model.new()
  o.enum.set("two")
  equal 2, o.enum.value

module "Field.bindPath"
test "may be used in path bindings", ->
  expect 1
  o = Model.new()
  o.bindPath ['boolean'], -> ok true
  o.boolean.set(true)

test "may be nested in path bindings", ->
  expect 1
  other = Model.new()
  o = Model.new(other:other)
  o.bindPath ['other', 'boolean'], -> ok true
  other.boolean.set(true)

module "Field.Sharing"
  setup: ->
    @o = Model.new()
    @share = makeDoc(null, {})
    @o.name.syncWith(@share)

test "propagate share value to model on sync", ->
  o = Model.new()
  share = makeDoc()
  share.at().set name: "from share"
  o.name.syncWith(share)
  equal "from share", o.name.get()

test "propagate field value to @share on sync", ->
  o = Model.new(name: "from model")
  share = makeDoc()
  share.at().set {}
  o.name.syncWith(share)
  equal "from model", share.at('name').get()


test "field updates when share is set", ->
  @share.emit "remoteop", @share.at('name').set("SET VALUE")
  equal "SET VALUE", @o.name.get()

test "share updates when field is set", ->
  @o.name.set("NOTIFIED")
  equal "NOTIFIED", @share.at('name').get()

test "field updates on share insert", ->
  @o.name.set("abc")
  @share.emit "remoteop", @share.at('name').insert(0, "123")
  equal "123abc", @o.name.get()

test "field updates on share delete", ->
  @o.name.set("Co123llin")
  @share.emit "remoteop", @share.at('name').del(2, 3)
  equal "Collin", @o.name.get()
