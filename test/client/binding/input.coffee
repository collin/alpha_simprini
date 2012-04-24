{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  Input:
    "sets input value on initialization": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      test.equal "value", binding.content.val()
      test.done()

    "updates input value when model changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      binding.model.field.set("changed value")
      test.equal "changed value", binding.content.val()
      test.done()

    "updates model value when input changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      binding.model.field.set("changed value")
      binding.content.val("user value").trigger("change")
      test.equal "user value", binding.model.field.get()
      test.done()

    "inherits from Field": (test) ->
      test.equal AS.Binding.Input.__super__.constructor, AS.Binding.Field
      test.done()
