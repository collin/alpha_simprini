helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, FieldModel, RelationModel} = helper
exports.setUp = coreSetUp

class Evented
  AS.Event.extends(this)

exports.Event =
  "trigger events without namespace": (test) ->
    test.expect 3
    o = new Evented
    o.bind "event.namespace", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true
    o.trigger "event"

    test.done()

  "trigger events with namespace": (test) ->
    test.expect 1
    o = new Evented
    o.bind "event2.namespace2", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true
    o.trigger "event.namespace2"
    o.trigger ".namespace2"

    test.done()

  "unbind events without namespace": (test) ->
    test.expect 1
    o = new Evented
    o.bind "event.namespace", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true
    o.unbind ".namespace2"
    o.unbind "event.namespace"
    o.trigger "event"
    o.trigger "event2"

    test.done()

  "unbind events with namespace": (test) ->
    o = new Evented

    test.expect 2

    o.bind "event.namespace", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true

    o.unbind(".namespace2")
    o.trigger "event"

    test.done()

  "unbind all events": (test) ->
    o = new Evented

    test.expect 0

    o.bind "event.namespace", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true

    o.unbind()
    o.trigger "event"

    test.done()