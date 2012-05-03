module "BindingGroup"
test "has a unique namespace", ->
  bg1 = AS.BindingGroup.new()
  bg2 = AS.BindingGroup.new()

  notEqual bg1.namespace, bg2.namespace
  equal bg1.namespace[0], "b"


test "binds to jquery objects", ->
  expect 1
  bg = AS.BindingGroup.new()

  object = $("<target>")

  bg.binds object, "event", -> ok(true)

  object.trigger("event")

test "binds to AS.Event event model", ->
  expect 4

  bg = AS.BindingGroup.new()
  _handler = ->
  object = bind: ({event, namespace, handler, context}) ->
    equal event, "event"
    equal namespace, bg.namespace
    equal handler, _handler
    equal context, object

  bg.binds object, "event", _handler, object

test "unbinds bound objects", ->
  expect 1
  bg = AS.BindingGroup.new()

  object =
    bind: ->
    unbind: (namespace) ->
      equal namespace,  "."+bg.namespace

  handler = ->
  bg.binds object, "event", handler, object
  bg.unbind()

test "unbinds bound objects in nested binding groups", ->
  parent = AS.BindingGroup.new()
  child = parent.addChild()

  object =
    bind: ->
    unbind: (namespace) ->
      equal namespace, "."+child.namespace

  handler = ->
  child.binds object, "event", handler, object
  parent.unbind()

    