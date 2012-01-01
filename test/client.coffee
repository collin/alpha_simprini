$ = require "jquery"

global.document = $("body")[0]._ownerDocument
global.window = document._parentWindow


AS = require("alpha_simprini")
AS.require("client")
_ = require "underscore"

sinon = require "sinon"

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
    mock.expects("bind").withExactArgs("event#{bg.namespace}", handler, object)
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
  @has_many "items"
  @belongs_to "owner"
    
mock_binding = (binding_class, _options={}) ->
  context = _options.context or new AS.View
  model = _options.model or new BoundModel field: "value"
  field = _options.field or "field"
  options = _options.options or {}
  fn = _options.fn or ->
  
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
    test.equal binding.field_value(), "value"
    
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
      mocks.model.object.field("new value")
      test.equal binding.container.find("span").text(), "new value"
      test.done()
    
    "uses given fn to generate content": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Field, fn: -> "fn value")
      test.equal binding.container.find("span").text(), "fn value"
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

      
  EditLine:
    "FIXME: figure out how to test rangy": (test) ->
      
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
  
  Collection:
    "field_value is the model": (test) ->
      [mocks, binding] = mock_binding(AS.Binding.Collection, model: new AS.Collection)
      test.equal binding.field_value(), binding.model
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
      
      
  
