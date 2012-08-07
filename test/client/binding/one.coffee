{mockBinding,BoundModel} = NS
module "Binding.One",
  setup: ->
    @model = BoundModel.new( owner: BoundModel.new() )

    content_fn = (thing) ->
      @div id: thing.cid.replace('.', '-')

    [mocks, binding] = mockBinding(AS.Binding.One, field: @model.owner, model: @model, fn: content_fn)

    @binding = binding

test "creates initial dom", ->
  ok @binding.content.find("##{@model.owner.get().cid.replace('.', '-')}").is("div")

test "clears dom when field is null", ->
  @binding.model.owner.set(null)
  Taxi.Governer.exit()
  equal undefined, @model.owner.get()
  equal "", @binding.content.html()

test "does nothing when model properties change", ->
  el = @binding.content.containerChildren[0]
  @binding.model.owner.get().field.set("Changed Name")
  equal el, @binding.content.containerChildren[0]

test "passes a model binding to the content_fn", ->
  @binding.fn = (model, binding) ->
    equal AS.Binding.Model, binding.constructor

  @binding.setContent()