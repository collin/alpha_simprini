{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

class Delegator
  AS.Delegate.extends(this)
  @delegate "property", to: "propertydelegate"
  @delegate "method", to: "methoddelegate"

  propertydelegate: property: (arg) -> "value #{arg}"


exports.delegate =
  propertyDelegate: (test) ->
    test.equal "value 2", (new Delegator).property("2")
    test.done()

  methodDelegate: (test) ->
    test.equal "value", (new Delegator).method()
    test.done()
