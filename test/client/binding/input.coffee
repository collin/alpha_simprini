{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  Input:
    "sets input value on initialization": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      test.equal binding.container.find("input").val(), "value"
      test.done()

    "updates input value when model changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      binding.model.field.set("changed value")
      test.equal binding.container.find("input").val(), "changed value"
      test.done()

    "updates model value when input changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      binding.model.field.set("changed value")
      binding.container.find("input").val("user value").trigger("change")
      test.equal binding.model.field.get(), "user value"
      test.done()

    "inherits from Field": (test) ->
      test.equal AS.Binding.Input.__super__.constructor, AS.Binding.Field
      test.done()
