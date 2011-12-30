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
  
    
    
    
    