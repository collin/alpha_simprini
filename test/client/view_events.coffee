{AS, $, _, sinon, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp
exports.ViewEvents =
  "delegates events": (test) ->
    test.expect 3

    BoundView = AS.View.extend ({def}) ->
      def events:
        "click": "click_handler"
        "click button": "button_handler"
        "event @member": "member_handler"

      def initialize: ->
        @member = AS.Model.new()
        @_super.apply(this, arguments)
        @_button = @$ @button()

      def click_handler: -> test.ok true
      def member_handler: -> test.ok true
      def button_handler: -> test.ok true
      def guard_fail_handler: -> test.ok true
      def guard_pass_handler: -> test.ok true

    view = BoundView.new()

    view.member.trigger("event")
    view._button.trigger("click")

    test.done()

  # rethinkign stately and other types of event guarding
  # "registers state event": (test) ->
  #   StatelyView = AS.View.extend ({def}) ->
  #     def left_events:
  #       "event": "event_handler"

  #     def right_events:
  #       "other_event": "other_event_handler"

  #     def event_handler: ->
  #     def other_event_handler: ->

  #   view = StatelyView.new()

  #   test.ok view.state_events.left instanceof AS.ViewEvents
  #   test.ok view.state_events.right instanceof AS.ViewEvents


  #   test.done()

  # "bind and unbinds state events on state changes": (test) ->
  #   test.expect 5

  #   StatelyView = AS.View.extend ({def}) ->

  #     def left_events:
  #       "click": "event_handler"

  #     def right_events:
  #       "click": "other_event_handler"

  #     def event_handler: -> test.equal "left", @state
  #     def other_event_handler: -> test.ok "right", @state

  #   view = StatelyView.new()

  #   view.bind "exitstate:left", -> test.ok true
  #   view.bind "enterstate:left", -> test.ok true
  #   view.bind "exitstate:right", -> test.ok true
  #   view.bind "enterstate:right", -> test.ok true

  #   view.transition_state from: undefined, to: "left"
  #   view.el.trigger "click"

  #   view.transition_state from: "left", to: "right"
  #   view.el.trigger "click"


  #   test.done()

  # "bind state transition events": (test) ->
  #   StatelyView = AS.View.extend ({def}) ->
  #     def left_events:
  #       "click": "event_handler"
  #       "crank @": transition:
  #         from: "left", to: "right"

  #     def right_events:
  #       "click": "other_event_handler"
  #       "crank @": transition:
  #         from: "right", to: "left"

  #     def event_handler: -> test.equal "left", @state
  #     def other_event_handler: -> test.ok "right", @state

  #     def initialize: ->
  #       @_super()
  #       @default_state("left")

  #   view = StatelyView.new()
  #   view.trigger 'crank'
  #   test.equal view.state, "right"
  #   view.trigger 'crank'
  #   test.equal view.state, "left"

  #   test.done()
