{makeDoc} = NS

F = Pathology.Namespace.new("Field")

Model = F.Model = AS.Model.extend()
Model.field "name"
Model.field "band", default: "the Tijuana Brass"
Model.field "number", type: AS.Model.Number
Model.field "boolean", type: AS.Model.Boolean
Model.field "enum", type: AS.Model.Enum, values: ["zero", "one", "two"]
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
  equal Model.properties.name.options.type, AS.Model.String

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
  Taxi.Governer.exit()
  o.number.set 43
  Taxi.Governer.exit()

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
  Taxi.Governer.exit()

test "may be nested in path bindings", ->
  expect 1
  other = Model.new()
  o = Model.new(other:other)
  o.bindPath ['other', 'boolean'], -> ok true
  other.boolean.set(true)
  Taxi.Governer.exit()

# module "Field.Sharing"
#   setup: ->
#     @o = Model.new()

#     snap = "Field.Model": {}
#     snap["Field.Model"][@o.id] = {}

#     @doc = makeDoc(null, snap)
#     @doc.open = -> # Avoid talking to ShareJS over the wire
#     adapter = AS.Model.ShareJSAdapter.new("url", "documentName")
#     adapter.share = @doc
#     adapter.bindRemoteOperationHandler()

#     @subDoc = @doc.at(["Field.Model", @o.id])
#     @o.name.syncWith(@subDoc)

# test "propagate share value to model on sync", ->
#   o = Model.new()
#   share = makeDoc()
#   share.at().set name: "from share"
#   o.name.syncWith(share)
#   equal o.name.get(), "from share"

# test "propagate field value to @share on sync", ->
#   o = Model.new(name: "from model")
#   share = makeDoc()
#   share.at().set {}
#   o.name.syncWith(share)
#   equal "from model", share.at('name').get()

# test "field updates when share is set", ->
#   @doc.emit "remoteop", @subDoc.at('name').set("SET VALUE")
#   equal @o.name.get(), "SET VALUE"

# test "share updates when field is set", ->
#   @o.name.set("NOTIFIED")
#   Taxi.Governer.exit()
#   equal @subDoc.at('name').get(), "NOTIFIED"

# test "field updates on share insert", ->
#   @o.name.set("abc")
#   Taxi.Governer.exit()
#   @doc.emit "remoteop", @subDoc.at('name').insert(0, "123")
#   equal @o.name.get(), "123abc"

# test "field updates on share delete", ->
#   @o.name.set("Co123llin")
#   Taxi.Governer.exit()
#   @doc.emit "remoteop", @subDoc.at('name').del(2, 3)
#   equal @o.name.get(), "Collin"
