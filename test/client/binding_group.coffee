{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
module "BindingGroup"
test "has a unique namespace", ->
  bg1 = AS.BindingGroup.new()
  bg2 = AS.BindingGroup.new()

  notEqual bg1.namespace, bg2.namespace
  equal bg1.namespace[0], "b"

  
test "binds to jquery objects", ->
  bg = AS.BindingGroup.new()

  object = jquery: true, bind: ->
  mock = sinon.mock(object)
  handler = ->

  mock.expects("bind").withArgs("event.#{bg.namespace}")
  bg.binds object, "event", handler

  mock.verify()

  
test "binds to AS.Event event model", ->
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

  
test "unbinds bound objects", ->
  bg = AS.BindingGroup.new()

  object =
    bind: ->
    unbind: ->

  mock = sinon.mock(object)
  handler = ->
  mock.expects("unbind").withExactArgs("."+bg.namespace)
  bg.binds object, "event", handler, object
  bg.unbind()
  mock.verify()

  

test "unbinds bound objects in nested binding groups", ->
  parent = AS.BindingGroup.new()
  child = parent.addChild()

  object =
    bind: ->
    unbind: ->

  mock = sinon.mock(object)
  handler = ->
  mock.expects("unbind").withExactArgs("."+child.namespace)
  child.binds object, "event", handler, object
  parent.unbind()
  mock.verify()

    