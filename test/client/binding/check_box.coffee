{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  CheckBox:
    "the checkbox is checked if the starting value is true": (test) ->
      model = BoundModel.new maybe: true
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      test.ok binding.container.find("input").is(":checked")
      test.done()

    "the checkbox is unchecked if the starting value is false": (test) ->
      model = BoundModel.new maybe: false
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      test.ok binding.container.find("input").is(":not(:checked)")
      test.done()

    "checking the box sets the field to true": (test) ->
      model = BoundModel.new maybe: false
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      binding.container.find("input").click().trigger("change")
      test.equal model.maybe.get(), true
      test.done()

    "unchecking the box sets the field to false": (test) ->
      model = BoundModel.new maybe: true
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      binding.container.find("input").click().trigger("change")
      test.equal model.maybe.get(), false
      test.done()
