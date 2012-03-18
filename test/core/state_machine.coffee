{AS, NS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp


Car = NS.Car = AS.Object.extend ({include, def}) ->
  include AS.StateMachine

  def initialize: -> @defaultState "off"

exports.StateMachine =
  hasDefaultState: (test) ->
    test.equal Car.new().state, "off"
    test.done()

  "will not transition from the wrong state": (test) ->
    car = Car.new()
    car.transitionState from: "wrongstate", to: "on"
    test.equal car.state, "off"
    test.done()

  "calls transition method with options for a valid transition": (test) ->
    test.expect 2
    car = Car.new()
    car.exit_off = (options) ->
      test.deepEqual from: "off", to: "on", options

    car.enter_on = (options) ->
      test.deepEqual from: "off", to: "on", options

    car.transitionState from: "off", to: "on"

    test.done()

