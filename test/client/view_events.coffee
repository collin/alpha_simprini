{AS, $, _, sinon, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

module "ViewEvents"
test "delegates events", ->
  expect 3

  BoundView = AS.View.extend ({def}) ->
    def events:
      "click": "click_handler"
      "click button": "button_handler"
      "event @member": "member_handler"

    def initialize: ->
      @member = AS.Model.new()
      @_super.apply(this, arguments)
      @_button = @$ @button()

    def click_handler: -> ok true
    def member_handler: -> ok true
    def button_handler: -> ok true
    def guard_fail_handler: -> ok true
    def guard_pass_handler: -> ok true

  view = BoundView.new()

  view.member.trigger("event")
  view._button.trigger("click")

    
  # rethinkign stately and other types of event guarding
  # "registers state event", ->
  #   StatelyView = AS.View.extend ({def}) ->
  #     def left_events:
  #       "event": "event_handler"

  #     def right_events:
  #       "other_event": "other_event_handler"

  #     def event_handler: ->
  #     def other_event_handler: ->

  #   view = StatelyView.new()

  #   ok view.state_events.left instanceof AS.ViewEvents
  #   ok view.state_events.right instanceof AS.ViewEvents


  #   
  # "bind and unbinds state events on state changes", ->
  #   expect 5

  #   StatelyView = AS.View.extend ({def}) ->

  #     def left_events:
  #       "click": "event_handler"

  #     def right_events:
  #       "click": "other_event_handler"

  #     def event_handler: -> equal "left", @state
  #     def other_event_handler: -> ok "right", @state

  #   view = StatelyView.new()

  #   view.bind "exitstate:left", -> ok true
  #   view.bind "enterstate:left", -> ok true
  #   view.bind "exitstate:right", -> ok true
  #   view.bind "enterstate:right", -> ok true

  #   view.transition_state from: undefined, to: "left"
  #   view.el.trigger "click"

  #   view.transition_state from: "left", to: "right"
  #   view.el.trigger "click"


  #   
  # "bind state transition events", ->
  #   StatelyView = AS.View.extend ({def}) ->
  #     def left_events:
  #       "click": "event_handler"
  #       "crank @": transition:
  #         from: "left", to: "right"

  #     def right_events:
  #       "click": "other_event_handler"
  #       "crank @": transition:
  #         from: "right", to: "left"

  #     def event_handler: -> equal "left", @state
  #     def other_event_handler: -> ok "right", @state

  #     def initialize: ->
  #       @_super()
  #       @defaultState("left")

  #   view = StatelyView.new()
  #   view.trigger 'crank'
  #   equal view.state, "right"
  #   view.trigger 'crank'
  #   equal view.state, "left"

  #   