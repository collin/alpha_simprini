{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

exports.InstanceMethods =
  discoversInstanceMethods: (test) ->
    class HasMethods
      a: 1
      b: 2

      test.deepEqual AS.instance_methods(HasMethods), ["a", "b"]
      test.done()

  traversesClasses: (test) ->
    class A
      a: 1

    class B extends A
      b: 2

      test.deepEqual AS.instance_methods(B), ["b", "a"]
      test.done()

class WithCallbacks
  AS.Callbacks.extends(this)
  @define_callbacks
    before: "this that".split(" ")

exports.Callbacks =
  definition: (test) ->
    it = WithCallbacks
    test.ok WithCallbacks.before_this
    test.ok WithCallbacks.before_that
    test.done()

  running: (test) ->
    test.expect(2)

    it = WithCallbacks
    cb = -> test.ok(true)
    it.before_this cb
    it.before_that cb

    one = new WithCallbacks
    one.run_callbacks "before_this"
    one.run_callbacks "before_that"

    test.done()
