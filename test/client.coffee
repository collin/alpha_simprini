$ = require "jquery"

global.document = $("body")[0]._ownerDocument
global.window = document._parentWindow


AS = require("alpha_simprini")
AS.require("client")
AS.suppress_logging()
_ = require "underscore"

sinon = require "sinon"

#TODO: move into a test helper module
makeDoc = (name="document_name", snapshot=null) ->
  share = require "share"
  Doc = share.client.Doc
  doc = new Doc {}, name, 0, share.types.json, snapshot
  # FIXME: get proper share server running in the tests
  # as it is we seem to be able to skip over the "pendingOp" stuff
  # but it'd be nicer to properly test his out.
  doc.submitOp = (op, callback) ->
    op = @type.normalize(op) if @type.normalize?
    @snapshot = @type.apply @snapshot, op
    #
    # # If this throws an exception, no changes should have been made to the doc
    #
    # if pendingOp != null
    #   pendingOp = @type.compose(pendingOp, op)
    # else
    #   pendingOp = op
    #
    pendingCallbacks.push callback if callback
    #
    @emit 'change', op
    #
    # # A timeout is used so if the user sends multiple ops at the same time, they'll be composed
    # # together and sent together.
    setTimeout @flush, 0
    op
    # console.log op, callback
  doc

exports.DOM =
  "creates document fragments": (test) ->
    html = (new AS.DOM).html ->
      @head ->
        @title "This is the Title"
      @body ->
        @h1 "This is the Header"
        @section ->
          @p "I'm the body copy :D"
        @div "data-custom": "attributes!"

    test.equal $(html).find("title").text(), "This is the Title"
    test.equal $(html).find("h1").text(), "This is the Header"
    test.equal $(html).find("p").text(), "I'm the body copy :D"
    test.equal $(html).find("[data-custom]").data().custom, "attributes!"

    test.done()

  "appends raw (scary html) content": (test) ->
    raw = (new AS.DOM).raw("<html>")
    test.ok $(raw).find("html").is("html")
    test.done()

  "appends escaped (non-scary html) content": (test)->
    raw = (new AS.DOM).span -> @text("<html>")
    test.equal $(raw).find("html")[0], undefined
    test.done()


exports.View =
  "generates klass strings": (test) ->
    test.equal new AS.View().klass_string(), "", "basic klass_string is ASView"

    class SomeView extends AS.View

    test.equal new SomeView().klass_string(), "SomeView", "subclasses include parent class string"

    test.done()

  "builds an element": (test) ->
    test.ok (new AS.View).el.is("div")
    class ListView extends AS.View
      tag_name: "ol"
    test.ok (new ListView).el.is("ol")
    test.done()

  "sets options from constructor": (test) ->
    test.equal (new AS.View this: "that").this, "that"
    test.done()

  "turns Model options into ASViewModels": (test) ->
    test.ok (new AS.View it: new AS.Model).it instanceof AS.ViewModel
    test.done()

  "has a root binding group": (test) ->
    test.ok (new AS.View).binding_group instanceof AS.BindingGroup
    test.done()

  "pluralizes text": (test) ->
    view = new AS.View
    test.equal view.pluralize("cat", 4), "cats"
    test.equal view.pluralize("person", 0), "people"
    test.equal view.pluralize("duck", 1), "duck"
    test.equal view.pluralize("duck", -1), "duck"
    test.equal view.pluralize("cat", -4), "cats"
    test.done()

exports.ViewEvents =
  "delegates events": (test) ->
    test.expect 4

    class BoundView extends AS.View
      events:
        "click": "click_handler"
        "click button": "button_handler"
        "event @member": "member_handler"
        "pass{pass:true} @member": "guard_pass_handler"
        "fail{pass:false} @member": "guard_fail_handler"

      constructor: ->
        @member = new AS.Model
        super

      initialize: ->
        @_button = @$ @button()

      click_handler: -> test.ok true
      member_handler: -> test.ok true
      button_handler: -> test.ok true
      guard_fail_handler: -> test.ok true
      guard_pass_handler: -> test.ok true

    view = new BoundView

    view.el.trigger("click")
    view.member.trigger("event")
    view._button.trigger("click")
    view.member.trigger("pass", pass: true)
    view.member.trigger("fail", pass: true)

    test.done()

  "registers state event": (test) ->
    class StatelyView extends AS.View
      left_events:
        "event": "event_handler"

      right_events:
        "other_event": "other_event_handler"

      event_handler: ->
      other_event_handler: ->

    view = new StatelyView

    test.ok view.state_events.left instanceof AS.ViewEvents
    test.ok view.state_events.right instanceof AS.ViewEvents


    test.done()

  "bind and unbinds state events on state changes": (test) ->
    test.expect 5

    class StatelyView extends AS.View

      left_events:
        "click": "event_handler"

      right_events:
        "click": "other_event_handler"

      event_handler: -> test.equal "left", @state
      other_event_handler: -> test.ok "right", @state

    view = new StatelyView

    view.bind "exitstate:left", -> test.ok true
    view.bind "enterstate:left", -> test.ok true
    view.bind "exitstate:right", -> test.ok true
    view.bind "enterstate:right", -> test.ok true

    view.transition_state from: undefined, to: "left"
    view.el.trigger "click"

    view.transition_state from: "left", to: "right"
    view.el.trigger "click"


    test.done()

  "bind state transition events": (test) ->
    class StatelyView extends AS.View

      left_events:
        "click": "event_handler"
        "crank @": transition:
          from: "left", to: "right"

      right_events:
        "click": "other_event_handler"
        "crank @": transition:
          from: "right", to: "left"

      event_handler: -> test.equal "left", @state
      other_event_handler: -> test.ok "right", @state

      initialize: ->
        super
        @default_state("left")

    view = new StatelyView
    view.trigger 'crank'
    test.equal view.state, "right"
    view.trigger 'crank'
    test.equal view.state, "left"

    test.done()

class Viewed extends AS.Model
  @field "field"
  @embeds_many "embeds"
  @embeds_one "embed"
  @has_many "relations"
  @has_one "relation"
  @belongs_to "owner"

  @virtual_properties "field"
    one: ->
    two: ->

  other: ->
exports.ViewModel =
  "builds viewmodels": (test) ->
    view = new AS.View
    model = new AS.Model
    vm = AS.ViewModel.build view, model

    test.equal vm.view, view
    test.equal vm.model, model

    test.done()

  "caches constructors": (test) ->
    vm1 = AS.ViewModel.build new AS.View, new AS.Model
    vm2 = AS.ViewModel.build new AS.View, new AS.Model

    test.equal vm1.constructor, vm2.constructor

    test.done()

  "configures constructor": (test) ->
    vm = AS.ViewModel.build new AS.View, new Viewed
    bindables = vm.constructor.bindables

    test.equal bindables.field, AS.Binding.Field
    test.equal bindables.embeds, AS.Binding.EmbedsMany
    test.equal bindables.embed, AS.Binding.EmbedsOne
    test.equal bindables.relations, AS.Binding.HasMany
    test.equal bindables.relation, AS.Binding.HasOne
    test.equal bindables.owner, AS.Binding.BelongsTo
    test.equal bindables.one, AS.Binding.Field
    test.equal bindables.one, AS.Binding.Field

    test.done()

  "delegates all model methods to model": (test) ->
    vm = AS.ViewModel.build new AS.View, new Viewed

    delegate = new RegExp

    for method in "field embeds embed relations relation owner other".split(" ")
      test.ok vm[method].toString().indexOf("return this.model[method].apply(this.model, arguments);")

    test.done()

exports.BindingGroup =
  "has a unique namespace": (test) ->
    bg1 = new AS.BindingGroup
    bg2 = new AS.BindingGroup

    test.notEqual bg1.namespace, bg2.namespace
    test.equal bg1.namespace[0], "."

    test.done()

  "binds to jquery objects": (test) ->
    bg = new AS.BindingGroup

    object = jquery: true, bind: ->
    mock = sinon.mock(object)
    handler = ->

    mock.expects("bind").withExactArgs("event#{bg.namespace}", handler)
    bg.binds object, "event", handler

    mock.verify()

    test.done()

  "binds to AS.Event event model": (test) ->
    bg = new AS.BindingGroup

    object = bind: ->
    mock = sinon.mock(object)
    handler = ->
    mock.expects("bind").withExactArgs({path: ["event"], namespace: bg.namespace}, handler, object)
    bg.binds object, "event", handler, object
    mock.verify()

    test.done()

  "unbinds bound objects": (test) ->
    bg = new AS.BindingGroup

    object =
      bind: ->
      unbind: ->

    mock = sinon.mock(object)
    handler = ->
    mock.expects("unbind").withExactArgs(bg.namespace)
    bg.binds object, "event", handler, object
    bg.unbind()
    mock.verify()

    test.done()


  "unbinds bound objects in nested binding groups": (test) ->
    parent = new AS.BindingGroup()
    child = parent.add_child()

    object =
      bind: ->
      unbind: ->

    mock = sinon.mock(object)
    handler = ->
    mock.expects("unbind").withExactArgs(child.namespace)
    child.binds object, "event", handler, object
    parent.unbind()
    mock.verify()

    test.done()

class BoundModel extends AS.Model
  @field "field"
  @has_many "items", model: -> SimpleModel
  @belongs_to "owner"

class SharedBoundModel extends BoundModel
  AS.Model.Share.extends this, "ShareBoundModel"

class SimpleModel extends AS.Model
  @field "field"

mock_binding = (binding_class, _options={}) ->
  context = _options.context or new AS.View
  model = _options.model or new BoundModel field: "value"
  field = _options.field or "field"
  options = _options.options or {}
  fn = _options.fn or undefined

  binding = new binding_class context, model, field, options, fn

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
    test.equal binding.container[0], binding.context.current_node

    test.done()

  "stashes the binding group": (test) ->
    [mocks, binding] = mock_binding(AS.Binding)
    test.equal binding.binding_group, binding.context.binding_group

    test.done()

  "gets the field value": (test) ->
    [mocks, binding] = mock_binding(AS.Binding)
    test.equal binding.path_value(), "value"

    test.done()

  Model:

    "paints styles": (test) ->
      context = new AS.View
      context_mock = sinon.mock context
      content = $("<div>")
      content_mock = sinon.mock content
      model = new AS.Model
      binding = new AS.Binding.Model context, model, content

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
      context = new AS.View
      context_mock = sinon.mock context
      content = $("<div>")
      content_mock = sinon.mock content
      model = new AS.Model
      binding = new AS.Binding.Model context, model, content

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
      binding.model.field("new value")
      test.equal binding.container.find("span").text(), "new value"
      test.done()

    "uses given fn to generate content": (test) ->
      [mocks, binding] = mock_binding AS.Binding.Field,
        fn: ->
          @h1 -> @span "fn value"

      test.equal binding.container.find("h1 > span").text(), "fn value"
      test.done()

    "updates fn content when value changes": (test) ->
      model = new BoundModel field: "value"
      [mocks, binding] = mock_binding AS.Binding.Field,
        model: model
        fn: ->
          @h1 -> @span model.field()

      test.equal binding.container.find("h1 > span").text(), "value"
      binding.model.field("changed value")
      test.equal binding.container.find("h1 > span").text(), "changed value"
      test.done()


  Input:
    "sets input value on initialization": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      test.equal binding.container.find("input").val(), "value"
      test.done()

    "updates input value when model changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      binding.model.field("changed value")
      test.equal binding.container.find("input").val(), "changed value"
      test.done()

    "updates model value when input changes": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Input)
      binding.model.field("changed value")
      binding.container.find("input").val("user value").trigger("change")
      test.equal binding.model.field(), "user value"
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
      model = new BoundModel field: "value"
      options = ["notvalue", "value"]
      [mocks, binding] = mock_binding(AS.Binding.Select, options: (options: options), model: model)

      test.equal binding.container.find("select").val(), "value"

      test.done()

    "sets value of dom when model value changes": (test) ->
      model = new BoundModel field: "value"
      options = ["notvalue", "value"]
      [mocks, binding] = mock_binding(AS.Binding.Select, options: (options: options), model: model)

      model.field("notvalue")

      test.equal binding.container.find("select").val()[0], "notvalue"

      test.done()

    "sets value on object when dom changes": (test) ->
      model = new BoundModel field: "value"
      options = ["notvalue", "value"]
      [mocks, binding] = mock_binding(AS.Binding.Select, options: (options: options), model: model)

      binding.container.find("select").val("notvalue")
      binding.container.find("select").trigger("change")

      test.equal model.field(), "notvalue"

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

    "contenteditable area responds to all edit events": (test) ->
      test.expect 8
      class EditLine extends AS.Binding.EditLine
        generate_operation: -> test.ok true
      [mocks, binding] = mock_binding(EditLine)
      mocks.binding.expects("applyChange").exactly(0)
      for event in ['textInput', 'keydown', 'keyup', 'select', 'cut', 'paste', 'click', 'focus']
        binding.content.trigger(event)
      mocks.verify()
      test.done()

    "applies change if content has changed on edit event": (test) ->
      model = SharedBoundModel.open()
      model.field("value")
      model.when_indexed =>
        [mocks, binding] = mock_binding(AS.Binding.EditLine, model: model)
        binding.content[0].innerHTML += " change"
        binding.generate_operation()
        test.deepEqual model.share.get(), model.attributes_for_sharing()
        test.done()

    "applies change from remote operation": (test) ->
      model = SharedBoundModel.open()
      model.field("value")
      model.when_indexed =>
        [mocks, binding] = mock_binding(AS.Binding.EditLine, model: model)
        @remote model.share.at("field").insert(0, "remote "), model
        test.equal binding.content[0].innerHTML, "remote value"
        test.equal model.share.at("field").get(), "remote value"
        test.equal model.field(), "remote value"
        test.done()

  HasMany:
    setUp: (callback) ->
      model = new BoundModel
      items = model.items()
      items.add()
      items.add()
      items.add()


      content_fn = (thing) -> @div id: thing.cid

      [mocks, binding] = mock_binding(AS.Binding.HasMany, field: 'items', model: model, fn: content_fn)

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
      model = new BoundModel
      items = model.items()

      content_fn = (thing) -> @div id: thing.cid

      [mocks, binding] = mock_binding(
        AS.Binding.HasMany,
          field: 'items',
          model: model,
          fn: content_fn
          options: filter: (field: [true, "43"])
        )

      @items = items
      @binding = binding
      callback()

    "filters items in the collection": (test) ->
      one = @items.add field: true
      two = @items.add field: false
      three = @items.add field: "43"

      test.equal @binding.container.find("##{one.cid}")[0].id, one.cid
      test.equal @binding.container.find("##{two.cid}")[0], undefined
      test.equal @binding.container.find("##{three.cid}")[0].id, three.cid
      test.done()

    "moves items into place in the collection when their values change": (test) ->
      one = @items.add field: true
      two = @items.add field: false
      three = @items.add field: true

      two.field("43")

      test.equal @binding.container.children()[1].id, two.cid

      test.done()

    "removes items when their values change": (test) ->
      one = @items.add field: true

      one.field(false)

      test.equal @binding.container.children().length, 0
      test.done()

  Collection:
    "field_value is the model": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Collection, model: new AS.Collection)
      test.equal binding.path_value(), binding.model
      test.done()

  EmbedsMany:
    "extends AS.Binding.HasMany": (test) ->
      test.equal AS.Binding.EmbedsMany.__super__.constructor, AS.Binding.HasMany
      test.done()

  EmbedsOne:
    "extends AS.Binding.Field": (test) ->
      test.equal AS.Binding.EmbedsOne.__super__.constructor, AS.Binding.Field
      test.done()

  HasOne:
    "extends AS.Binding.Field": (test) ->
      test.equal AS.Binding.HasOne.__super__.constructor, AS.Binding.Field
      test.done()

  BelongsTo:
    setUp: (callback) ->
      owner = new AS.Model
      model = new BoundModel
      model.owner owner

      content_fn = (thing) -> @div id: thing.cid

      [mocks, binding] = mock_binding(AS.Binding.BelongsTo, field: 'owner', model: model, fn: content_fn)

      @owner = owner
      @binding = binding
      callback()

    "initializes content": (test) ->
      test.ok @binding.container.find("##{@owner.cid}").is("div")
      test.done()

    "removes content when relation set to null": (test) ->
      @binding.model.owner(null)
      test.equal @binding.container.html(), ""
      test.done()

    "creates content when relation set": (test) ->
      new_owner = new AS.Model
      @binding.model.owner new_owner
      test.ok @binding.container.find("##{new_owner.cid}").is("div")
      test.done()

exports.Views =
  Panel:
    "Panel extends View": (test) ->
      test.ok new AS.Views.Panel instanceof AS.View
      test.done()

  Regions:
    "regions for cardinal directions/center extend Region": (test) ->
      test.ok new AS.Views.Region instanceof AS.View
      test.ok new AS.Views.North instanceof AS.Views.Region
      test.ok new AS.Views.East instanceof AS.Views.Region
      test.ok new AS.Views.South instanceof AS.Views.Region
      test.ok new AS.Views.West instanceof AS.Views.Region
      test.ok new AS.Views.Center instanceof AS.Views.Region
      test.done()

jwerty = require("jwerty").jwerty
exports.Application =
  setUp: (callback) ->
    @app = new AS.Application
    callback()

  "attaches global key handlers w/jwerty": (test) ->
    test.expect 3
    @app.bind "esc", (event) -> test.ok event
    @app.bind "accept", (event) -> test.ok event
    @app.bind "delete", (event) -> test.ok event
    jwerty.fire "esc"
    jwerty.fire "cmd+enter"
    jwerty.fire "backspace"
    test.done()

  "initializes views into the application context": (test) ->
    app_panel = @app.view AS.Views.Panel, key: "value"
    test.equal app_panel.application, @app
    test.equal app_panel.key, "value"
    test.done()

  "appends views into the app dom element": (test) ->
    app_panel = @app.view AS.Views.Panel, key: "value"
    @app.append app_panel
    test.equal @app.el.children()[0], app_panel.el[0]
    test.done()

class SomeTargets extends AS.Models.Targets
  selector: "target"

class ClientRect
  top: 0
  left: 0
  width: 0
  height: 0

  constructor: (properties) ->
    require("underscore").extend(this, properties)
    @right = @left + @width
    @bottom = @top + @height

exports.Targets =
  setUp: (callback) ->
    body = $("body")
    body.empty()
    body.append "<target />"
    body.append "<target />"
    body.append "<target />"

    targets = $("target")
    @t1 = targets[0]
    @t2 = targets[1]
    @t3 = targets[2]

    @t1.getBoundingClientRect = ->
      new ClientRect width: 100, height: 50

    @t2.getBoundingClientRect = ->
      new ClientRect top: 50, width: 100, height: 50

    @t3.getBoundingClientRect = ->
      new ClientRect top: 100, width: 100, height: 50

    callback()

  "gathers targets": (test) ->
    targets = (new SomeTargets).targets
    test.equal targets.length, 3
    test.equal targets[1].el[0], @t2
    test.equal targets[1].rect.top, 50, 'top'
    test.equal targets[1].rect.right, 100, 'right'
    test.equal targets[1].rect.bottom, 100, 'bottom'
    test.equal targets[1].rect.left, 0, 'left'
    test.equal targets[1].rect.width, 100, 'width'
    test.equal targets[1].rect.height, 50, 'height'
    test.done()

  "dropend triggers dropend event": (test) ->
    targets = new SomeTargets
    test.expect 1
    targets.bind "dropend", -> test.ok true
    targets.dropend()
    test.done()

  "dropstart triggers dropstart event if current hit has a rect": (test) ->
    targets = new SomeTargets
    hit = rect: true
    targets.current_hit = hit
    test.expect 1
    targets.bind "dropstart", (thehit) -> test.equal hit, thehit
    targets.dropstart()
    test.done()

  "dropstart is a noop if current hit lacks a rect": (test) ->
    targets = new SomeTargets
    test.expect 0
    targets.bind "dropstart", -> test.ok true
    targets.dropstart()
    test.done()

  "dragend calls drop and triggers drop if current hit has a rect": (test) ->
    targets = new SomeTargets
    hit = rect: true
    data = new Object
    targets.current_hit = hit
    test.expect 2
    targets.bind "drop", (thehit) -> test.equal hit, thehit
    targets.drop = (thedata) -> test.equal thedata, data
    targets.dragend(data)
    test.done()

  "dragend is a noop if current hit lacks a rect": (test) ->
    targets = new SomeTargets
    data = new Object
    test.expect 0
    targets.bind "drop", (thehit) -> test.equal hit, thehit
    targets.drop = (thedata) -> test.equal thedata, data
    targets.dragend(data)
    test.done()

  "transition_hit()":
    "noop if hit has no rect": (test) ->
      targets = new SomeTargets
      targets.dropend = -> test.ok true
      test.expect 0
      targets.transition_hit {}
      test.done()

    "noop if currenth hit equals hit": (test) ->
      targets = new SomeTargets
      targets.current_hit = equals: -> true
      targets.dropend = -> test.ok true
      test.expect 0
      targets.transition_hit {}
      test.done()

    "transitions if current hit does not equal hit": (test) ->
      targets = new SomeTargets
      targets.current_hit = equals: -> false
      hit = rect: true
      test.expect 2
      targets.dropend = ->
        test.ok targets.current_hit isnt hit
      targets.dropstart = ->
        test.ok targets.current_hit is hit
      targets.transition_hit hit
      test.done()


target_event = (x, y) ->
  return {
    "jquery/event": originalEvent:
      clientX: x, clientY: y
  }

exports.Targets.Edge =
  setUp: (callback) ->
    @targets = new AS.Models.Targets.Edge
    @el = {}
    @rect = new ClientRect width: 100, height: 50
    @targets.targets = [
      el: @el
      rect: @rect
    ]
    callback()

  "vertical_target":
    setUp: (callback) ->
      @check = (x, y) =>
        @targets.vertical_target target_event(x, y)
      callback()

    "misses when not inside box": (test) ->
      test.equal null, @check(-1, -1), "before"
      test.equal null, @check(101, 51), "after"
      test.equal null, @check(70, 101), "inside x, outside y"
      test.equal null, @check(50, 130), "outside x, inside y"
      test.done()

    "hits when inside the box": (test) ->
      test.ok @check(100, 80), "within edge x, inside y"
      test.ok @check(0, -30), "within edge x, inside y"
      test.done()

    "hits TOP/BOTTOM": (test) ->
      hit = @check(0, 0)
      test.equal hit.section, hit.TOP

      hit = @check(0, 50)
      test.equal hit.section, hit.BOTTOM
      test.done()

  "horizontal_target":
    setUp: (callback) ->
      @check = (x, y) =>
        @targets.horizontal_target target_event(x, y)
      callback()

    "misses when not inside box": (test) ->
      test.equal null, @check(-1, -1), "before"
      test.equal null, @check(101, 51), "after"
      test.equal null, @check(70, 101), "outside x, inside y"
      test.equal null, @check(50, 50), "inside x, outside y"
      test.done()

    "hits when inside the box": (test) ->
      test.ok @check(130, 50), "within x, inside edge y"
      test.ok @check(-30, 0), "within x, inside edge y"
      test.done()

    "hits LEFT/RIGHT": (test) ->
      hit = @check(0, 0)
      test.equal hit.section, hit.LEFT

      hit = @check(100, 0)
      test.equal hit.section, hit.RIGHT

      test.done()

exports.Targets.Thirds =
  setUp: (callback) ->
    @targets = new AS.Models.Targets.Thirds
    @el = {}
    @rect = new ClientRect width: 100, height: 50
    @targets.targets = [
      el: @el
      rect: @rect
    ]

    @check = (x, y) =>
      @targets.target target_event(x, y)
    callback()


  "misses when not inside vertically": (test) ->
    test.equal null, @check(0, -1), "before"
    test.equal null, @check(0, 51), "after"
    test.done()

  "hits TOP/MIDDLE/BOTTOM": (test) ->
    hit = @check(0, 0)
    test.equal hit.section, hit.TOP

    hit = @check(0, 25)
    test.equal hit.section, hit.MIDDLE

    hit = @check(0, 50)
    test.equal hit.section, hit.BOTTOM

    test.done()

































