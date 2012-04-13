{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  Field:
    "sets appropriate initial content": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Field)
      test.equal binding.container.find("span").text(), "value"
      test.done()

    "clears content when value undefined": (test) ->
      [mocks, binding] = mock_binding AS.Binding.Field,
        fn: ->
          @h1 -> @span "fn value"

      binding.model.field.set(undefined)
      test.equal "", binding.container.html()
      test.done()

    "clears content when value null": (test) ->
      [mocks, binding] = mock_binding AS.Binding.Field,
        fn: ->
          @h1 -> @span "fn value"

      binding.model.field.set(null)
      test.equal "", binding.container.html()
      test.done()

    "updates content when model changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Field)
      binding.model.field.set("new value")
      test.equal binding.container.find("span").text(), "new value"
      test.done()

    "uses given fn to generate content": (test) ->
      [mocks, binding] = mock_binding AS.Binding.Field,
        fn: ->
          @h1 -> @span "fn value"

      test.equal binding.container.find("h1 > span").text(), "fn value"
      test.done()

    "updates fn content when value changes": (test) ->
      model = BoundModel.new field: "value"
      [mocks, binding] = mock_binding AS.Binding.Field,
        model: model
        fn: ->
          @h1 -> @span model.field.get()

      test.equal binding.container.find("h1 > span").text(), "value"
      binding.model.field.set("changed value")
      test.equal binding.container.find("h1 > span").text(), "changed value"
      test.done()

