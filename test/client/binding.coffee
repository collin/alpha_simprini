{AS, NS, $, _, sinon, makeDoc, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

BoundModel = NS.BoundModel = AS.Model.extend()

BoundModel.field "field"
BoundModel.field "maybe", type: Boolean
BoundModel.hasMany "items", model: -> SimpleModel
BoundModel.hasOne "owner"

# class SharedBoundModel extends BoundModel
#   AS.Model.Share.extends this, "ShareBoundModel"

SimpleModel = NS.SimpleModel = AS.Model.extend()
SimpleModel.field "field"

mock_binding = (binding_class, _options={}) ->
  context = _options.context or AS.View.new()
  model = _options.model or BoundModel.new field: "value"
  field = _options.field or model["field"]
  options = _options.options or {}
  fn = _options.fn or undefined

  binding = binding_class.new context, model, field, options, fn

  mocks =
    binding: sinon.mock binding
    context: sinon.mock context
    model: sinon.mock model
    field: sinon.mock field
    options: sinon.mock options
    fn: sinon.mock options
    verify: ->
      @binding.verify()
      @context.verify()
      @model.verify()
      @field.verify()
      @options.verify()
      @fn.verify()

   [mocks, binding]

exports.Binding =
  "stashes the binding container": (test) ->
    [mocks, binding] = mock_binding(AS.Binding)

    test.equal binding.container[0], binding.context.currentNode

    test.done()

  "stashes the binding group": (test) ->
    [mocks, binding] = mock_binding(AS.Binding)
    test.equal binding.bindingGroup, binding.context.bindingGroup

    test.done()

  "gets the field value": (test) ->
    [mocks, binding] = mock_binding(AS.Binding)
    test.equal binding.fieldValue(), "value"

    test.done()

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

  Field:
    "sets appropriate initial content": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Field)
      test.equal binding.container.find("span").text(), "value"
      test.done()

    "updates content when model changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Field)
      binding.model.field.set("new value")
      test.equal binding.container.find("span").text(), "new value"
      test.done()

    "uses given fn to generate content": (test) ->
      [mocks, binding] = mock_binding AS.Binding.Field,
        fn: ->
          @h1 -> @span "fn value"

      test.equal binding.container.find("h1 > span").text(), "fn value"
      test.done()

    "updates fn content when value changes": (test) ->
      model = BoundModel.new field: "value"
      [mocks, binding] = mock_binding AS.Binding.Field,
        model: model
        fn: ->
          @h1 -> @span model.field.get()

      test.equal binding.container.find("h1 > span").text(), "value"
      binding.model.field.set("changed value")
      test.equal binding.container.find("h1 > span").text(), "changed value"
      test.done()


  Input:
    "sets input value on initialization": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      test.equal binding.container.find("input").val(), "value"
      test.done()

    "updates input value when model changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      binding.model.field.set("changed value")
      test.equal binding.container.find("input").val(), "changed value"
      test.done()

    "updates model value when input changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      binding.model.field.set("changed value")
      binding.container.find("input").val("user value").trigger("change")
      test.equal binding.model.field.get(), "user value"
      test.done()

    "inherits from Field": (test) ->
      test.equal AS.Binding.Input.__super__.constructor, AS.Binding.Field
      test.done()

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

  CheckBox:
    "the checkbox is checked if the starting value is true": (test) ->
      model = BoundModel.new maybe: true
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      test.ok binding.container.find("input").is(":checked")
      test.done()

    "the checkbox is unchecked if the starting value is false": (test) ->
      model = BoundModel.new maybe: false
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      test.ok binding.container.find("input").is(":not(:checked)")
      test.done()

    "checking the box sets the field to true": (test) ->
      model = BoundModel.new maybe: false
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      binding.container.find("input").click().trigger("change")
      test.equal model.maybe.get(), true
      test.done()

    "unchecking the box sets the field to false": (test) ->
      model = BoundModel.new maybe: true
      [mocks, binding] = mock_binding(AS.Binding.CheckBox, model: model, field: model.maybe)
      binding.container.find("input").click().trigger("change")
      test.equal model.maybe.get(), false
      test.done()


  EditLine:
    setUp: (callback) ->
      @rangy_api =
        getSelection: -> {
            rangeCount: 0
            createRange: -> {
              startOffset: 0
              endOffset: 0
            }
          }
        createRange: -> {
          startOffset: 0
          endOffset: 0
        }

      @real_open = AS.open_shared_object
      AS.open_shared_object = (id, did_open) ->
        did_open makeDoc(id)

      @remote = (operation, model = @model) ->
        if model.share.emit
          model.share.emit "remoteop", operation
        else
          model.share.doc.emit "remoteop", operation

      AS.Binding.EditLine::rangy = @rangy_api
      callback()

    tearDown: (callback) ->
      AS.open_shared_object = @real_open
      callback()

    # TODO: implement sharing things
    # "contenteditable area responds to all edit events": (test) ->
    #   test.expect 8
    #   EditLine = AS.Binding.EditLine.extend ({def}) ->
    #     def generate_operation: -> test.ok true
    #   [mocks, binding] = mock_binding(EditLine)
    #   mocks.binding.expects("applyChange").exactly(0)
    #   for event in ['textInput', 'keydown', 'keyup', 'select', 'cut', 'paste', 'click', 'focus']
    #     binding.content.trigger(event)
    #   mocks.verify()
    #   test.done()

    # "applies change if content has changed on edit event": (test) ->
    #   model = SharedBoundModel.open()
    #   model.field("value")
    #   model.when_indexed =>
    #     [mocks, binding] = mock_binding(AS.Binding.EditLine, model: model)
    #     binding.content[0].innerHTML += " change"
    #     binding.generate_operation()
    #     test.deepEqual model.share.get(), model.attributes_for_sharing()
    #     test.done()

    # "applies change from remote operation": (test) ->
    #   model = SharedBoundModel.open()
    #   model.field("value")
    #   model.when_indexed =>
    #     [mocks, binding] = mock_binding(AS.Binding.EditLine, model: model)
    #     @remote model.share.at("field").insert(0, "remote "), model
    #     test.equal binding.content[0].innerHTML, "remote value"
    #     test.equal model.share.at("field").get(), "remote value"
    #     test.equal model.field(), "remote value"
    #     test.done()

  Many:
    setUp: (callback) ->
      model = BoundModel.new()
      items = model.items
      items.add()
      items.add()
      items.add()


      content_fn = (thing) -> @div id: thing.cid

      [mocks, binding] = mock_binding(AS.Binding.Many, field: model.items, model: model, fn: content_fn)

      @items = items
      @binding = binding
      callback()

    "creates initial collection dom": (test) ->
      test.expect 3
      @items.each (item) =>
        test.ok @binding.container.find("##{item.cid}").is("div")

      test.done()

    "adds additional dom elements when items added to collection": (test) ->
      test.expect 1
      item = @items.add()
      test.ok @binding.container.find("##{item.cid}").is("div")

      test.done()

    "adds new dom elements at correct index": (test) ->
      test.expect 1
      item = @items.add({}, at: 0)

      test.ok @binding.container.children(":first").is("##{item.cid}")

      test.done()

    "removes dom elements when item removed from collection": (test) ->
      item = @items.at(0)
      @items.remove item
      test.ok @binding.container.find("##{item.cid}")[0] is undefined
      test.done()

  HasManyWithFilter:
    setUp: (callback) ->
      model = BoundModel.new()
      items = model.items

      content_fn = (thing) -> @div id: thing.cid

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

      test.equal @binding.container.find("##{one.cid}")[0].id, one.cid
      test.equal @binding.container.find("##{two.cid}")[0], undefined
      test.equal @binding.container.find("##{three.cid}")[0].id, three.cid
      test.done()

    "moves items into place in the collection when their values change": (test) ->
      one = @items.add field: true
      two = @items.add field: false
      three = @items.add field: true

      two.field.set("43")

      test.equal @binding.container.children()[1].id, two.cid

      test.done()

    "removes items when their values change": (test) ->
      one = @items.add field: true

      one.field.set(false)

      test.equal @binding.container.children().length, 0
      test.done()

  # Collection:
  #   "field_value is the model": (test) ->
  #     [mocks, binding] = mock_binding(AS.Binding.Collection, model: new AS.Collection)
  #     test.equal binding.pathValue(), binding.model
  #     test.done()

  # EmbedsMany:
  #   "extends AS.Binding.HasMany": (test) ->
  #     test.equal AS.Binding.EmbedsMany.__super__.constructor, AS.Binding.HasMany
  #     test.done()

  # EmbedsOne:
  #   "extends AS.Binding.Field": (test) ->
  #     test.equal AS.Binding.EmbedsOne.__super__.constructor, AS.Binding.Field
  #     test.done()

  # HasOne:
  #   "extends AS.Binding.Field": (test) ->
  #     test.equal AS.Binding.HasOne.__super__.constructor, AS.Binding.Field
  #     test.done()

  # BelongsTo:
  #   setUp: (callback) ->
  #     owner = new AS.Model
  #     model = new BoundModel
  #     model.owner owner

  #     content_fn = (thing) -> @div id: thing.cid

  #     [mocks, binding] = mock_binding(AS.Binding.BelongsTo, field: 'owner', model: model, fn: content_fn)

  #     @owner = owner
  #     @binding = binding
  #     callback()

  #   "initializes content": (test) ->
  #     test.ok @binding.container.find("##{@owner.cid}").is("div")
  #     test.done()

  #   "removes content when relation set to null": (test) ->
  #     @binding.model.owner(null)
  #     test.equal @binding.container.html(), ""
  #     test.done()

  #   "creates content when relation set": (test) ->
  #     new_owner = new AS.Model
  #     @binding.model.owner new_owner
  #     test.ok @binding.container.find("##{new_owner.cid}").is("div")
  #     test.done()
