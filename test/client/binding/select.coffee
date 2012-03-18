{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  Select:
    "must provide options option": (test) ->
      test.throws (-> mock_binding(AS.Binding.Select)), AS.Binding.MissingOption
      test.done()

    "uses provided Array for select options": (test) ->
      options = [1..3]
      [mocks, binding] = mock_binding(AS.Binding.Select, options: options: options)

      test.equal binding.container.find("option").length, 3
      test.equal binding.container.find("select").text(), "123"

      test.done()

    "uses provided Object for select options": (test) ->
      options =
        "one": 1
        "two": 2
        "three": 3
      [mocks, binding] = mock_binding(AS.Binding.Select, options: options: options)

      test.equal binding.container.find("option").length, 3

      for key, value of options
        test.equal $(binding.container.find("option[value='#{value}']")).text(), key

      test.done()

    "sets select value on initialization": (test) ->
      model = BoundModel.new field: "value"
      options = ["notvalue", "value"]
      [mocks, binding] = mock_binding(AS.Binding.Select, options: (options: options), model: model)

      test.equal binding.container.find("select").val(), "value"

      test.done()

    "sets value of dom when model value changes": (test) ->
      model = BoundModel.new field: "value"
      options = ["notvalue", "value"]
      [mocks, binding] = mock_binding(AS.Binding.Select, options: (options: options), model: model)

      model.field.set("notvalue")

      test.equal binding.container.find("select").val()[0], "notvalue"

      test.done()

    "sets value on object when dom changes": (test) ->
      model = BoundModel.new field: "value"
      options = ["notvalue", "value"]
      [mocks, binding] = mock_binding(AS.Binding.Select, options: (options: options), model: model)

      binding.container.find("select").val("notvalue")
      binding.container.find("select").trigger("change")

      test.equal model.field.get(), "notvalue"

      test.done()
