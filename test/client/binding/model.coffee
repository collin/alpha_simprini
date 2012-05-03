module "Binding.Model"

BM = Pathology.Namespace.new("BindingModel")
BM.Model = AS.Model.extend ({delegate, include, def, defs}) ->
  @field 'field1'
  @field 'field2'

test "paints styles", ->
  context = AS.View.new()
  context_mock = sinon.mock context
  content = $("<div>")
  content_mock = sinon.mock content
  model = BM.Model.new()
  binding = AS.Binding.Model.new context, model, content

  context_mock.expects('binds').withArgs(model, ["field1"])
  context_mock.expects('binds').withArgs(model, ["field2"])

  binding.css
    "background-color":
      fn: (model) -> model.bgcolor or "mock-color"
      field: ["field1"]

  binding.css
    "background-color":
      fn: (model) -> model.bgcolor or "mock-color"
      field: ["field2"]

  content_mock.expects("css").withExactArgs
    "background-color": "mock-color"

  binding.paint()

  model.bgcolor = "bgcolor"

  content_mock.expects("css").withExactArgs
    "background-color": "bgcolor"

  model.field1.trigger("change")
  model.field2.trigger("change")

  content_mock.verify()


test "paints attributes", ->
  context = AS.View.new()
  context_mock = sinon.mock context
  content = $("<div>")
  content_mock = sinon.mock content
  model = BM.Model.new()
  binding = AS.Binding.Model.new context, model, content

  context_mock.expects('binds').withArgs(model, ["field1"])
  context_mock.expects('binds').withArgs(model, ["field2"])

  binding.attr
    "data-property":
      fn: (model) -> model.property or "mock-value"
      field: ["field1"]

  binding.attr
    "data-property":
      fn: (model) -> model.property or "mock-value"
      field: ["field2"]

  content_mock.expects("attr").withExactArgs
    "data-property": "mock-value"

  binding.paint()

  model.property = "value2"

  content_mock.expects("attr").withExactArgs
    "data-property": "value2"

  model.field2.trigger("change")
  content_mock.verify()


  