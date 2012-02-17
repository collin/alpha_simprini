{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp


class Car
  AS.StateMachine.extends(this)

  constructor: -> @default_state "off"

exports.StateMachine =
  hasDefaultState: (test) ->
    test.equal (new Car).state, "off"
    test.done()

  "will not transition from the wrong state": (test) ->
    car = new Car
    car.transition_state from: "wrongstate", to: "on"
    test.equal car.state, "off"
    test.done()

  "calls transition method with options for a valid transition": (test) ->
    test.expect 2
    car = new Car
    car.exit_off = (options) ->
      test.deepEqual from: "off", to: "on", options

    car.enter_on = (options) ->
      test.deepEqual from: "off", to: "on", options

    car.transition_state from: "off", to: "on"

    test.done()

