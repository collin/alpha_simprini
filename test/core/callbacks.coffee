{AS, _, sinon, coreSetUp} = require require("path").resolve("./helper")
exports.setUp = coreSetUp

WithCallbacks = AS.Object.extend ({include}) ->
  include AS.Callbacks
  @defineCallbacks
    before: "this that".split(" ")

module "Callbacks"
test "definition", ->
  it = WithCallbacks
  ok WithCallbacks.beforeThis
  ok WithCallbacks.beforeThat

test "running", ->
  expect(2)

  it = WithCallbacks
  cb = -> ok(true)
  it.beforeThis cb
  it.beforeThat cb

  one = WithCallbacks.new()
  one.runCallbacks "beforeThis"
  one.runCallbacks "beforeThat"
