HO = Pathology.Namespace.new("Hasone")
HO.Parent = AS.Model.extend()
HO.Parent.hasOne "other", model: -> HO.Other

HO.Dependant = AS.Model.extend ({delegate, include, def, defs}) ->
  @hasOne "other", dependant: "destroy"

HO.Other = HO.Parent.extend()
HO.Other.field "name"

module "HasOne"
test "property is a HasOne", ->
    o = HO.Parent.new()
    ok o.other instanceof AS.Model.HasOne.Instance

test "collection events trigger on property", ->
  expect 1
  o = HO.Parent.new other: name: "Juliet"
  o.other.get().name.bind "change", -> ok true
  o.other.get().name.set "Julio"
  Taxi.Governer.exit()

test "change event triggers when model is set", ->
  expect 3, "fix field pass-through binding"
  o = HO.Parent.new()
  o.bind "change", -> ok true
  o.bind "change:other", -> ok true
  o.other.bind "change", -> ok true
  o.other.set {}
  Taxi.Governer.exit()

test "clears object when set to null", ->
  expect 4, "fix field pass-through binding"
  o = HO.Parent.new()
  o.bind "change", -> ok true
  o.bind "change:other", -> ok true
  o.other.bind "change", -> ok true
  o.other.set null
  Taxi.Governer.exit()
  equal undefined, o.other.get()

test "destroys value if dependant is destroy", ->
  expect 1
  o = HO.Dependant.new()
  o.other.set other = HO.Other.new()
  other.bind "destroy", -> ok true
  o.destroy()
  Taxi.Governer.exit()

test "nullifies value if other is destroyed", ->
  expect 1
  o = HO.Parent.new()
  o.other.set other = HO.Other.new()
  other.destroy()
  Taxi.Governer.exit()
  equal o.other.get(), null

module "HasOne is set when constructing the model"
test "with a model", ->
  o = HO.Parent.new other: other = AS.Model.new()
  equal other, o.other.get()

test "with a raw abject", ->
  o = HO.Parent.new other: name: "Linus"
  equal "Linus", o.other.get().name.get()

module "HasOne.bindPath"
test "may bind through hasOne by name", ->
  expect 2
  otherother = HO.Other.new()
  other = HO.Other.new(other:otherother)
  o = HO.Parent.new other: other

  o.bindPath ['other', 'other', 'name'], -> ok(true)

  otherother.name.set("other from another other's mother")

  other.other.set newother = HO.Other.new()

  otherother.name.set "simpler name"
  newother.name.set "new name"
  Taxi.Governer.exit()


test "may bind through ancestral hierarchy", ->
  expect 2
  otherother = HO.Other.new()
  other = HO.Other.new(other:otherother)
  o = HO.Parent.new other: other


  Taxi.Governer.exit()
  o.bindPath ['other', HO.Parent, 'name'], -> ok(true)

  otherother.name.set("other from another other's mother")

  other.other.set newother = HO.Other.new()

  otherother.name.set "simpler name"
  newother.name.set "new name"
  Taxi.Governer.exit()

