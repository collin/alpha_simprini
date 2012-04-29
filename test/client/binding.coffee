{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

module "Binding"
test "stashes the binding container", ->
  [mocks, binding] = mock_binding(AS.Binding)

  equal binding.container[0], binding.context.currentNode

  
test "stashes the binding group", ->
  [mocks, binding] = mock_binding(AS.Binding)
  equal binding.bindingGroup, binding.context.bindingGroup

  
test "gets the field value", ->
  [mocks, binding] = mock_binding(AS.Binding)
  equal binding.fieldValue(), "value"
