{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
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
    mock.expects("bind").withExactArgs({path: ["event"], namespace: bg.namespace}, handler, object)
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
