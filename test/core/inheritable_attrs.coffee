{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

class Parent
  AS.InheritableAttrs.extends(this)
  @push_inheritable_item "ancestors", "Grandpa"
  @write_inheritable_value "preferences", "food", "everything"

class Child extends Parent
  @extended()
  @push_inheritable_item "ancestors", "Dad"
  @write_inheritable_value "preferences", "food", "nothing"

Parent.write_inheritable_value "preferences", "this", "that"

exports.inheritable_attrs =
  childHasParentsAttrs: (test) ->
    test.deepEqual Child.ancestors, ["Grandpa", "Dad"]
    test.deepEqual Child.preferences, "food": "nothing"
    test.done()

  childValuesDontLeakUpwards: (test) ->
    test.deepEqual Parent.ancestors, ["Grandpa"]
    test.deepEqual Parent.preferences, this: "that", "food": "everything"
    test.done()
