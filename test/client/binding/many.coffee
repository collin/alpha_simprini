{mockBinding,BoundModel} = NS
module "Binding.Many",
  setup: ->
    model = BoundModel.new()
    items = model.items
    items.add()
    items.add()
    items.add()


    content_fn = (thing) -> @div id: thing.cid.replace(".", "-")

    [mocks, binding] = mockBinding(AS.Binding.Many, field: model.items, model: model, fn: content_fn)

    @items = items
    @binding = binding

test "creates initial collection dom", ->
  expect 3
  @items.each (item) =>
    ok @binding.container.find("##{item.cid.replace(".", "-")}").is("div")


test "adds additional dom elements when items added to collection", ->
  expect 1
  item = @items.add()
  ok @binding.container.find("##{item.cid.replace(".", "-")}").is("div")


test "adds new dom elements at correct index", ->
  expect 1
  item = @items.add({}, at: 0)

  ok @binding.container.children(":first").is("##{item.cid.replace(".", "-")}")


test "removes dom elements when item removed from collection", ->
  item = @items.at(0)
  @items.remove item
  ok @binding.container.find("##{item.cid.replace(".", "-")}")[0] is undefined

module "Binding.HasManyWithFilter"
  setup: ->
    model = BoundModel.new()
    items = model.items

    content_fn = (thing) -> @div id: thing.cid.replace(".", "-")

    [mocks, binding] = mockBinding(AS.Binding.Many,
        field: items,
        model: model,
        fn: content_fn
        options: filter: (field: ["true", "43"])
      )

    @items = items
    @binding = binding


test "filters items in the collection", ->
  one = @items.add field: "true"
  two = @items.add field: "false"
  three = @items.add field: "43"

  equal @binding.container.find("##{one.cid.replace(".", "-")}")[0].id, one.cid.replace(".", "-")
  equal @binding.container.find("##{two.cid.replace(".", "-")}")[0], undefined
  equal @binding.container.find("##{three.cid.replace(".", "-")}")[0].id, three.cid.replace(".", "-")

test "moves items into place in the collection when their values change", ->
  one = @items.add field: true
  two = @items.add field: false
  three = @items.add field: true

  two.field.set("43")

  equal @binding.container.children()[1].id, two.cid.replace(".", "-")


test "removes items when their values change", ->
  one = @items.add field: true

  one.field.set(false)

  equal @binding.container.children().length, 0
  