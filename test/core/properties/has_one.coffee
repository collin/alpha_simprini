HO = Pathology.Namespace.new("Hasone")
HO.Parent = AS.Model.extend()
HO.Parent.hasOne "other", model: -> HO.Other

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

test "change event triggers when model is set", ->
  expect 3, "fix field pass-through binding"
  o = HO.Parent.new()
  o.bind "change", -> ok true
  o.bind "change:other", -> ok true
  o.other.bind "change", -> ok true
  o.other.set {}

test "clears object when set to null", ->
  expect 4, "fix field pass-through binding"
  o = HO.Parent.new()
  o.bind "change", -> ok true
  o.bind "change:other", -> ok true
  o.other.bind "change", -> ok true
  o.other.set null
  equal undefined, o.other.get()

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

test "may bind through ancestral hierarchy", ->
  expect 2
  otherother = HO.Other.new()
  other = HO.Other.new(other:otherother)
  o = HO.Parent.new other: other

  o.bindPath ['other', HO.Parent, 'name'], -> ok(true)

  otherother.name.set("other from another other's mother")

  other.other.set newother = HO.Other.new()

  otherother.name.set "simpler name"
  newother.name.set "new name"
