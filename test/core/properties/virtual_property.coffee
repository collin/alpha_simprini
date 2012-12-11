class NS.Virtualized < AS.Model
  @field "name"
  @property "other"
  @hasMany "others"
  @virtualProperties "name", "others",
    virtualA: -> Math.random()
    virtualB: -> "steady as she goes"
    virtualC:
      get: -> @name.get()
      set: (value) -> @name.set(value)

class NS.Basic < AS.Model
  @field "name"

module "VirtualProperty"
test "is a virtual", ->
  ok NS.Virtualized.properties.virtualA instanceof AS.Model.VirtualProperty
  ok NS.Virtualized.properties.virtualB instanceof AS.Model.VirtualProperty

test "exposes dependencies", ->
  deepEqual NS.Virtualized.properties.virtualA.dependencies, ["name", "others"]

test "when dependency and virtual changes, change triggers on virtual", ->
  expect 1
  o = NS.Virtualized.new()
  o.bind "change:virtualA", -> ok true
  o.name.set "New Name"
  Taxi.Governer.exit()

# FIXME: this is HIGHLY desireable behavior, but it isn't strictly neccessary
# test "when dependency changes but virtual doesn't change, virtual doesn't trigger", ->
#   expect 1
#   o = NS.Virtualized.new()
#   o.bind "change:virtualB", -> ok(true)
#   o.name.set "First Name"
#   o.name.set "Second Name"

test "with a setter", ->
  o = NS.Virtualized.new()
  o.virtualC.set("vname")
  equal "vname", o.name.get()

test "may depend on collection properties", ->
  expect 3
  o = NS.Virtualized.new()
  o.bind "change:virtualA", -> ok true
  o.bind "change:virtualB", -> ok true
  o.bind "change:virtualC", -> ok true
  o.others.add {}
  Taxi.Governer.exit()

test "may depend on changing collection properties", ->
  expect 1
  o = NS.Virtualized.new()
  other = o.others.add NS.Basic.new()
  Taxi.Governer.exit()
  o.bind "change:virtualA", -> ok true
  o.others.at(0).name.set("NEW NAME")
  Taxi.Governer.exit()

module "Virtualized bindPath"
test "may be used in path bindings", ->
  expect 1
  o = NS.Virtualized.new()
  o.bindPath ['virtualA'], -> ok(true)
  o.name.set("my name")
  Taxi.Governer.exit()

test "may be nested in path bindings", ->
  expect 1
  other = NS.Virtualized.new()
  o = NS.Virtualized.new(other:other)
  o.bindPath ['other', 'virtualA'], -> ok(true)
  other.name.set("my name")
  Taxi.Governer.exit()

test "path may change", ->
  expect 3
  other = NS.Virtualized.new()
  o = NS.Virtualized.new(other:other)
  o.bindPath ['other', 'virtualA'], -> ok(true)
  other.name.set("my name")
  Taxi.Governer.exit()

  otherother = NS.Virtualized.new()
  o.other.set(otherother)
  Taxi.Governer.exit()

  otherother.name.set("MY name")
  Taxi.Governer.exit()
