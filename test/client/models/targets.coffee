NS.SomeTargets = AS.Models.Targets.extend ({def}) ->
  def selector: "target"

class ClientRect
  top: 0
  left: 0
  width: 0
  height: 0

  constructor: (properties) ->
    require("underscore").extend(this, properties)
    @right = @left + @width
    @bottom = @top + @height

module "Targets",
  setup: (callback) ->
    body = $("body")
    body.empty()
    body.append "<target />"
    body.append "<target />"
    body.append "<target />"

    targets = $("target")
    @t1 = targets[0]
    @t2 = targets[1]
    @t3 = targets[2]

    @t1.getBoundingClientRect = ->
      new ClientRect width: 100, height: 50

    @t2.getBoundingClientRect = ->
      new ClientRect top: 50, width: 100, height: 50

    @t3.getBoundingClientRect = ->
      new ClientRect top: 100, width: 100, height: 50

test "gathers targets", ->
    targets = NS.SomeTargets.new().targets
    equal targets.length, 3
    equal targets[1].el[0], @t2
    equal targets[1].rect.top, 50, 'top'
    equal targets[1].rect.right, 100, 'right'
    equal targets[1].rect.bottom, 100, 'bottom'
    equal targets[1].rect.left, 0, 'left'
    equal targets[1].rect.width, 100, 'width'
    equal targets[1].rect.height, 50, 'height'

test "dropend triggers dropend event", ->
    targets = NS.SomeTargets.new()
    expect 1
    targets.bind "dropend", -> ok true
    targets.dropend()

test "dropstart triggers dropstart event if current hit has a rect", ->
    targets = NS.SomeTargets.new()
    hit = rect: true
    targets.current_hit = hit
    expect 1
    targets.bind "dropstart", (thehit) -> equal hit, thehit
    targets.dropstart()

test "dropstart is a noop if current hit lacks a rect", ->
    targets = NS.SomeTargets.new()
    expect 0
    targets.bind "dropstart", -> ok true
    targets.dropstart()

test "dragend calls drop and triggers drop if current hit has a rect", ->
    targets = NS.SomeTargets.new()
    hit = rect: true
    data = new Object
    targets.current_hit = hit
    expect 2
    targets.bind "drop", (thehit) -> equal hit, thehit
    targets.drop = (thedata) -> equal thedata, data
    targets.dragend(data)

test "dragend is a noop if current hit lacks a rect", ->
    targets = NS.SomeTargets.new()
    data = new Object
    expect 0
    targets.bind "drop", (thehit) -> equal hit, thehit
    targets.drop = (thedata) -> equal thedata, data
    targets.dragend(data)

test "noop if hit has no rect", ->
      targets = NS.SomeTargets.new()
      targets.dropend = -> ok true
      expect 0
      targets.transition_hit {}

test "noop if currenth hit equals hit", ->
      targets = NS.SomeTargets.new()
      targets.current_hit = equals: -> true
      targets.dropend = -> ok true
      expect 0
      targets.transition_hit {}

test "transitions if current hit does not equal hit", ->
      targets = NS.SomeTargets.new()
      targets.current_hit = equals: -> false
      hit = rect: true
      expect 2
      targets.dropend = ->
        ok targets.current_hit isnt hit
      targets.dropstart = ->
        ok targets.current_hit is hit
      targets.transition_hit hit


target_event = (x, y) ->
  return {
      "jquery/event": originalEvent
      clientX: x, clientY: y
  }


setupEdgeTargets = ->
  @targets = AS.Models.Targets.Edge.new()
  @el = {}
  @rect = new ClientRect width: 100, height: 50
  @targets.targets = [
    el: @el
    rect: @rect
  ]

module "Targets.Edge",

module "Targets.Edge.vertical_target",
  setup: ->
    setupEdgeTargets.call(this)
    @check = (x, y) =>
      @targets.vertical_target target_event(x, y)
    callback()

test "misses when not inside box", ->
      equal null, @check(-1, -1), "before"
      equal null, @check(101, 51), "after"
      equal null, @check(70, 101), "inside x, outside y"
      equal null, @check(50, 130), "outside x, inside y"

test "hits when inside the box", ->
      ok @check(100, 80), "within edge x, inside y"
      ok @check(0, -30), "within edge x, inside y"

test "hits TOP/BOTTOM", ->
      hit = @check(0, 0)
      equal hit.section, hit.TOP

      hit = @check(0, 50)
      equal hit.section, hit.BOTTOM

module "Targets.Edge.horizontal_target",
  setup: (callback) ->
    setupEdgeTargets.call(this)
    @check = (x, y) =>
      @targets.horizontal_target target_event(x, y)
    callback()

test "misses when not inside box", ->
  equal null, @check(-1, -1), "before"
  equal null, @check(101, 51), "after"
  equal null, @check(70, 101), "outside x, inside y"
  equal null, @check(50, 50), "inside x, outside y"

test "hits when inside the box", ->
  ok @check(130, 50), "within x, inside edge y"
  ok @check(-30, 0), "within x, inside edge y"

test "hits LEFT/RIGHT", ->
  hit = @check(0, 0)
  equal hit.section, hit.LEFT

  hit = @check(100, 0)
  equal hit.section, hit.RIGHT


module "Targets.Thirds",
  setup: ->
    @targets = AS.Models.Targets.Thirds.new()
    @el = {}
    @rect = new ClientRect width: 100, height: 50
    @targets.targets = [
      el: @el
      rect: @rect
    ]

    @check = (x, y) =>
      @targets.target target_event(x, y)
    callback()

test "misses when not inside vertically", ->
    equal null, @check(0, -1), "before"
    equal null, @check(0, 51), "after"

test "hits TOP/MIDDLE/BOTTOM", ->
    hit = @check(0, 0)
    equal hit.section, hit.TOP

    hit = @check(0, 25)
    equal hit.section, hit.MIDDLE

    hit = @check(0, 50)
    equal hit.section, hit.BOTTOM


