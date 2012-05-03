{mockBinding, BoundModel} = NS

module "Binding.Select"
test "must provide options option", ->
  raises (-> mockBinding(AS.Binding.Select)), AS.Binding.MissingOption

test "uses provided Array for select options", ->
  options = [1..3]
  [mocks, binding] = mockBinding(AS.Binding.Select, options: options: options)

  equal binding.container.find("option").length, 3
  equal binding.container.find("select").text(), "123"


test "uses provided Object for select options", ->
  options =
    "one": 1
    "two": 2
    "three": 3
  [mocks, binding] = mockBinding(AS.Binding.Select, options: options: options)

  equal binding.container.find("option").length, 3

  for key, value of options
    equal $(binding.container.find("option[value='#{value}']")).text(), key


test "sets select value on initialization", ->
  model = BoundModel.new field: "value"
  options = ["notvalue", "value"]
  [mocks, binding] = mockBinding(AS.Binding.Select, options: (options: options), model: model)

  equal binding.container.find("select").val(), "value"


test "sets value of dom when model value changes", ->
  model = BoundModel.new field: "value"
  options = ["notvalue", "value"]
  [mocks, binding] = mockBinding(AS.Binding.Select, options: (options: options), model: model)

  model.field.set("notvalue")

  equal binding.container.find("select").val(), "notvalue"


test "sets value on object when dom changes", ->
  model = BoundModel.new field: "value"
  options = ["notvalue", "value"]
  [mocks, binding] = mockBinding(AS.Binding.Select, options: (options: options), model: model)

  binding.container.find("select").val("notvalue")
  binding.container.find("select").trigger("change")

  equal model.field.get(), "notvalue"

      