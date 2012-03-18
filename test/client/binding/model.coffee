{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  Model:

    "paints styles": (test) ->
      context = AS.View.new()
      context_mock = sinon.mock context
      content = $("<div>")
      content_mock = sinon.mock content
      model = AS.Model.new()
      binding = AS.Binding.Model.new context, model, content

      context_mock.expects('binds').withArgs(model, "change:field1")
      context_mock.expects('binds').withArgs(model, "change:field2")

      binding.css
        "background-color":
          fn: (model) -> model.bgcolor or "mock-color"
          field: "field1 field2"

      content_mock.expects("css").withExactArgs
        "background-color": "mock-color"

      binding.paint()

      model.bgcolor = "bgcolor"

      content_mock.expects("css").withExactArgs
        "background-color": "bgcolor"

      model.trigger("change:field1")

      test.done()

    "paints attributes": (test) ->
      context = AS.View.new()
      context_mock = sinon.mock context
      content = $("<div>")
      content_mock = sinon.mock content
      model = AS.Model.new()
      binding = AS.Binding.Model.new context, model, content

      context_mock.expects('binds').withArgs(model, "change:field1")
      context_mock.expects('binds').withArgs(model, "change:field2")

      binding.attr
        "data-property":
          fn: (model) -> model.property or "mock-value"
          field: "field1 field2"

      content_mock.expects("attr").withExactArgs
        "data-property": "mock-value"

      binding.paint()

      model.property = "value2"

      content_mock.expects("attr").withExactArgs
        "data-property": "value2"

      model.trigger("change:field2")

      test.done()
