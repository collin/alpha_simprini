{mockBinding,BoundModel} = NS
module "Binding.CheckBox"

test "there is only one check box", ->
  model = BoundModel.new maybe: true
  [mocks, binding] = mockBinding(AS.Binding.CheckBox, model: model, field: model.maybe)
  equal 1, binding.content.parent().find(":checkbox").length

test "the checkbox is checked if the starting value is true", ->
  model = BoundModel.new maybe: true
  [mocks, binding] = mockBinding(AS.Binding.CheckBox, model: model, field: model.maybe)
  ok binding.content.is(":checked")

test "the checkbox is unchecked if the starting value is false", ->
  model = BoundModel.new maybe: false
  [mocks, binding] = mockBinding(AS.Binding.CheckBox, model: model, field: model.maybe)
  ok binding.content.is(":not(:checked)")

test "checking the box sets the field to true", ->
  model = BoundModel.new maybe: false
  [mocks, binding] = mockBinding(AS.Binding.CheckBox, model: model, field: model.maybe)
  binding.content.click().trigger("change")
  equal model.maybe.get(), true

test "unchecking the box sets the field to false", ->
  model = BoundModel.new maybe: true
  [mocks, binding] = mockBinding(AS.Binding.CheckBox, model: model, field: model.maybe)
  binding.content.click().trigger("change")
  equal model.maybe.get(), false
  