helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp


NS.Virtualized = AS.Model.extend ->
  @field "name"
  @property "other"
  @virtualProperties "name",
    virtualA: -> Math.random()
    virtualB: -> "steady as she goes"

exports.VirtualProperty =
  "is a virtual": (test) ->
    test.ok NS.Virtualized.properties.virtualA instanceof AS.Model.VirtualProperty
    test.ok NS.Virtualized.properties.virtualB instanceof AS.Model.VirtualProperty    
    test.done()

  "exposes dependencies": (test) ->
    test.deepEqual NS.Virtualized.properties.virtualA.dependencies, ["name"]
    test.done()

  "when dependency and virtual changes, change triggers on virtual": (test) ->
    o = NS.Virtualized.new()
    o.bind "change:virtualA", -> test.done()
    o.name.set "New Name"

  "when dependency changes but virtual doesn't change, virtual doesn't trigger": (test) ->
    test.expect 1
    o = NS.Virtualized.new()
    o.bind "change:virtualB", -> test.ok(true)
    o.name.set "First Name"
    o.name.set "Second Name"
    test.done()

  "bindPath": 
    "may be used in path bindings": (test) ->
      o = NS.Virtualized.new()
      o.bindPath ['virtualA'], -> test.done()
      o.name.set("my name")

    "may be nested in path bindings": (test) ->
      test.expect 1
      other = NS.Virtualized.new()
      o = NS.Virtualized.new(other:other)
      o.bindPath ['other', 'virtualA'], -> test.ok(true)
      other.name.set("my name")
      test.done()

    "path may change": (test) ->
      test.expect 2
      other = NS.Virtualized.new()
      o = NS.Virtualized.new(other:other)
      o.bindPath ['other', 'virtualA'], -> test.ok(true)
      other.name.set("my name")

      otherother = NS.Virtualized.new()
      o.other.set(otherother)
      otherother.name.set("MY name")
      test.done()


