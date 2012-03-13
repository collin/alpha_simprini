{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
exports.BindingGroup =
  "has a unique namespace": (test) ->
    bg1 = AS.BindingGroup.new()
    bg2 = AS.BindingGroup.new()

    test.notEqual bg1.namespace, bg2.namespace
    test.equal bg1.namespace[0], "b"

    test.done()

  "binds to jquery objects": (test) ->
    bg = AS.BindingGroup.new()

    object = jquery: true, bind: ->
    mock = sinon.mock(object)
    handler = ->

    mock.expects("bind").withExactArgs("event.#{bg.namespace}", handler)
    bg.binds object, "event", handler

    mock.verify()

    test.done()

  "binds to AS.Event event model": (test) ->
    bg = AS.BindingGroup.new()

    object = bind: ->
    mock = sinon.mock(object)
    handler = ->
    mock.expects("bind").withExactArgs
        event: "event"
        namespace: bg.namespace
        handler: handler
        context: object
    bg.binds object, "event", handler, object
    mock.verify()

    test.done()

  "unbinds bound objects": (test) ->
    bg = AS.BindingGroup.new()

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
    parent = AS.BindingGroup.new()
    child = parent.addChild()

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
