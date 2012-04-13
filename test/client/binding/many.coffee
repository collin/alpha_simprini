{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  Many:
    setUp: (callback) ->
      model = BoundModel.new()
      items = model.items
      items.add()
      items.add()
      items.add()


      content_fn = (thing) -> @div id: thing.cid.replace(".", "-")

      [mocks, binding] = mock_binding(AS.Binding.Many, field: model.items, model: model, fn: content_fn)

      @items = items
      @binding = binding
      callback()

    "creates initial collection dom": (test) ->
      test.expect 3
      @items.each (item) =>
        test.ok @binding.container.find("##{item.cid.replace(".", "-")}").is("div")

      test.done()

    "adds additional dom elements when items added to collection": (test) ->
      test.expect 1
      item = @items.add()
      test.ok @binding.container.find("##{item.cid.replace(".", "-")}").is("div")

      test.done()

    "adds new dom elements at correct index": (test) ->
      test.expect 1
      item = @items.add({}, at: 0)

      test.ok @binding.container.children(":first").is("##{item.cid.replace(".", "-")}")

      test.done()

    "removes dom elements when item removed from collection": (test) ->
      item = @items.at(0)
      @items.remove item
      test.ok @binding.container.find("##{item.cid.replace(".", "-")}")[0] is undefined
      test.done()

  HasManyWithFilter:
    setUp: (callback) ->
      model = BoundModel.new()
      items = model.items

      content_fn = (thing) -> @div id: thing.cid.replace(".", "-")

      [mocks, binding] = mock_binding(AS.Binding.Many,
          field: items,
          model: model,
          fn: content_fn
          options: filter: (field: ["true", "43"])
        )

      @items = items
      @binding = binding
      callback()

    "filters items in the collection": (test) ->
      one = @items.add field: "true"
      two = @items.add field: "false"
      three = @items.add field: "43"

      test.equal @binding.container.find("##{one.cid.replace(".", "-")}")[0].id, one.cid.replace(".", "-")
      test.equal @binding.container.find("##{two.cid.replace(".", "-")}")[0], undefined
      test.equal @binding.container.find("##{three.cid.replace(".", "-")}")[0].id, three.cid.replace(".", "-")
      test.done()

    "moves items into place in the collection when their values change": (test) ->
      one = @items.add field: true
      two = @items.add field: false
      three = @items.add field: true

      two.field.set("43")

      test.equal @binding.container.children()[1].id, two.cid.replace(".", "-")

      test.done()

    "removes items when their values change": (test) ->
      one = @items.add field: true

      one.field.set(false)

      test.equal @binding.container.children().length, 0
      test.done()