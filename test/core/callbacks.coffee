{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

WithCallbacks = AS.Object.extend ({include}) ->
  include AS.Callbacks
  @defineCallbacks
    before: "this that".split(" ")

exports.Callbacks =
  definition: (test) ->
    it = WithCallbacks
    test.ok WithCallbacks.beforeThis
    test.ok WithCallbacks.beforeThat
    test.done()

  running: (test) ->
    test.expect(2)

    it = WithCallbacks
    cb = -> test.ok(true)
    it.beforeThis cb
    it.beforeThat cb

    one = WithCallbacks.new()
    one.runCallbacks "beforeThis"
    one.runCallbacks "beforeThat"

    test.done()
