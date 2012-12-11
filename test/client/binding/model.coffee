module "Binding.Model"

BM = Pathology.Namespace.new("BindingModel")
BM.Model = AS.Model.extend ({delegate, include, def, defs}) ->
  @field 'field1'
  @field 'field2'

test "paints styles", ->
  context = AS.View.new()
  content = $("<div>")
  model = BM.Model.new()
  binding = AS.Binding.Model.new context, model, content

  model.field1.set("rgb(34, 34, 34)")

  binding.css
    "background-color": ["field1"]

  binding.paint()
  equal content.css("background-color"), "rgb(34, 34, 34)"

  model.field1.set("rgb(0, 0, 0)")
  Taxi.Governer.exit()
  equal content.css("background-color"), "rgb(0, 0, 0)"

test "paints attributes", ->
  context = AS.View.new()
  content = $("<div>")
  model = BM.Model.new()
  model.field1.set("mock-value")
  binding = AS.Binding.Model.new context, model, content
  binding.attr
    "data-property": ["field1"]


  binding.paint()
  equal content.data().property, "mock-value"

  binding.attr
    "data-property2": ["field2"]

  model.field2.set("value2")
  Taxi.Governer.exit()

  equal content.attr('data-property2'), "value2"


  