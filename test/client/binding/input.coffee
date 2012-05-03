mockBinding = NS.mockBinding
module "Binding.Input"
test "sets input value on initialization", ->
  [mocks, binding] = mockBinding(AS.Binding.Input)
  equal "value", binding.content.val()

test "updates input value when model changes", ->
  [mocks, binding] = mockBinding(AS.Binding.Input)
  binding.model.field.set("changed value")
  equal "changed value", binding.content.val()

test "updates model value when input changes", ->
  [mocks, binding] = mockBinding(AS.Binding.Input)
  binding.model.field.set("changed value")
  binding.content.val("user value").trigger("change")
  equal "user value", binding.model.field.get()

test "inherits from Field", ->
  equal AS.Binding.Input.__super__.constructor, AS.Binding.Field
  