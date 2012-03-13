{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

WithCallbacks = AS.Object.extend ({include}) ->
  include AS.Callbacks
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

    one = WithCallbacks.new()
    one.run_callbacks "before_this"
    one.run_callbacks "before_that"

    test.done()
