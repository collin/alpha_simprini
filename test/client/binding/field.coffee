{BoundModel,mockBinding} = NS
module "Binding.Field"

test "sets appropriate initial content", ->
  [mocks, binding] = mockBinding(AS.Binding.Field)
  equal binding.container.find("span").text(), "value"

test "clears content when value undefined", ->
  [mocks, binding] = mockBinding AS.Binding.Field,
    fn: ->
      @h1 -> @span "fn value"

  binding.model.field.set(undefined)
  equal "", binding.container.html()

test "clears content when value null", ->
  [mocks, binding] = mockBinding AS.Binding.Field,
    fn: ->
      @h1 -> @span "fn value"

  binding.model.field.set(null)
  equal "", binding.container.html()

test "updates content when model changes", ->
  [mocks, binding] = mockBinding(AS.Binding.Field)
  binding.model.field.set("new value")
  equal binding.container.find("span").text(), "new value"

test "uses given fn to generate content", ->
  [mocks, binding] = mockBinding AS.Binding.Field,
    fn: ->
      @h1 -> @span "fn value"

  equal binding.container.find("h1 > span").text(), "fn value"

test "updates fn content when value changes", ->
  model = BoundModel.new field: "value"
  [mocks, binding] = mockBinding AS.Binding.Field,
    model: model
    fn: ->
      @h1 -> @span model.field.get()

  equal binding.container.find("h1 > span").text(), "value"
  binding.model.field.set("changed value")
  equal binding.container.find("h1 > span").text(), "changed value"

