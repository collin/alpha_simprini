{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
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
