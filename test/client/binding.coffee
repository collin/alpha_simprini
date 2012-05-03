mockBinding = NS.mockBinding

module "Binding"
test "stashes the binding container", ->
  [mocks, binding] = mockBinding(AS.Binding)
  equal binding.container[0], binding.context.currentNode

test "stashes the binding group", ->
  [mocks, binding] = mockBinding(AS.Binding)
  equal binding.bindingGroup, binding.context.bindingGroup

test "gets the field value", ->
  [mocks, binding] = mockBinding(AS.Binding)
  equal binding.fieldValue(), "value"
