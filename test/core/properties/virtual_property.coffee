helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp


NS.Virtualized = AS.Model.extend ->
  @field "name"
  @virtualProperties "name",
    virtualA: -> Math.random()
    virtualB: -> "steady as she goes"

exports.VirtualProperty =
  "is a virtual": (test) ->
    test.ok NS.Virtualized.properties.virtualA instanceof AS.Model.VirtualProperty
    test.ok NS.Virtualized.properties.virtualB instanceof AS.Model.VirtualProperty    
    test.done()

  "exposes dependencies": (test) ->
    test.deepEqual NS.Virtualized.properties.virtualA.options.dependencies, ["name"]
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
