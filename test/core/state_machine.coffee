Car = NS.Car = AS.Object.extend ({include, def}) ->
  include AS.StateMachine

  def initialize: -> @defaultState "off"

module "StateMachine"
test "hasDefaultState",  ->
  equal Car.new().state, "off"

test "will not transition from the wrong state", ->
  car = Car.new()
  car.transitionState from: "wrongstate", to: "on"
  equal car.state, "off"

test "calls transition method with options for a valid transition", ->
  expect 2
  car = Car.new()
  car.exit_off = (options) ->
    deepEqual from: "off", to: "on", options

  car.enter_on = (options) ->
    deepEqual from: "off", to: "on", options

  car.transitionState from: "off", to: "on"
