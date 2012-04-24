{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  CheckBox:
    "there is only one check box": (test) ->
      model = BoundModel.new maybe: true
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      test.equal 1, binding.content.parent().find(":checkbox").length
      test.done()

    "the checkbox is checked if the starting value is true": (test) ->
      model = BoundModel.new maybe: true
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      test.ok binding.content.is(":checked")
      test.done()

    "the checkbox is unchecked if the starting value is false": (test) ->
      model = BoundModel.new maybe: false
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      test.ok binding.content.is(":not(:checked)")
      test.done()

    "checking the box sets the field to true": (test) ->
      model = BoundModel.new maybe: false
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      binding.content.click().trigger("change")
      test.equal model.maybe.get(), true
      test.done()

    "unchecking the box sets the field to false": (test) ->
      model = BoundModel.new maybe: true
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      binding.content.click().trigger("change")
      test.equal model.maybe.get(), false
      test.done()
