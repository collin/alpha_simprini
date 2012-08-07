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
  Taxi.Governer.exit()
  equal "", binding.container.html()

test "clears content when value null", ->
  [mocks, binding] = mockBinding AS.Binding.Field,
    fn: ->
      @h1 -> @span "fn value"

  binding.model.field.set(null)
  Taxi.Governer.exit()
  equal "", binding.container.html()

test "updates content when model changes", ->
  [mocks, binding] = mockBinding(AS.Binding.Field)
  binding.model.field.set("new value")
  Taxi.Governer.exit()
  equal binding.container.find("span").text(), "new value"

test "uses given fn to generate content", ->
  [mocks, binding] = mockBinding AS.Binding.Field,
    fn: ->
      @h1 -> @span "fn value"

  Taxi.Governer.exit()
  equal binding.container.find("h1 > span").text(), "fn value"

test "updates fn content when value changes", ->
  model = BoundModel.new field: "value"
  [mocks, binding] = mockBinding AS.Binding.Field,
    model: model
    fn: ->
      @h1 -> @span model.field.get()

  Taxi.Governer.exit()
  equal binding.container.find("h1 > span").text(), "value"
  binding.model.field.set("changed value")
  Taxi.Governer.exit()
  equal binding.container.find("h1 > span").text(), "changed value"

test "if binding renders 'then' content when truthy", ->
  model = BoundModel.new field: "truthy"
  [mocks, binding] = mockBinding AS.Binding.If,
    model: model
    options:
      then: ->
        @h1 -> "then"

  equal binding.container.find("h1").text(), "then"

test "if binding renders no content when falsey and no 'else' branch given", ->
  model = BoundModel.new field: null
  [mocks, binding] = mockBinding AS.Binding.If,
    model: model
    options:
      then: ->
        @h1 -> "then"

  deepEqual binding.container.text(), ""

test "if binding renders 'else' content when falsey", ->
  model = BoundModel.new field: null
  [mocks, binding] = mockBinding AS.Binding.If,
    model: model
    options:
      then: ->
        @h1 -> "then"
      else: ->
        @h1 -> "else"

  equal binding.container.find("h1").text(), "else"

test "if binding changes content when field changes", ->
  model = BoundModel.new maybe: null
  [mocks, binding] = mockBinding AS.Binding.If,
    model: model
    field: 'maybe'
    options:
      then: ->
        @h1 -> "then"
      else: ->
        @h1 -> "else"

  model.maybe.set(true)
  Taxi.Governer.exit()
  equal binding.container.find("h1").text(), "then", true

  model.maybe.set(false)
  Taxi.Governer.exit()
  equal binding.container.find("h1").text(), "else", false

  model.maybe.set(true)
  Taxi.Governer.exit()
  equal binding.container.find("h1").text(), "then", true
