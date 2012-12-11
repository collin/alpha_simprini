class NS.SomeTargets < AS.Models.Targets
  def selector: "target"

class NS.ClientRect
  def initialize: (properties) ->
    @top = 0
    @left = 0
    @width = 0
    @height = 0

    _.extend this, properties
    console.log "NS.ClientRect", properties, this

    @right = @left + @width
    @bottom = @top + @height

ClientRect = NS.ClientRect

module "Targets",
  setup: ->
    body = $("body")
    body.append "<target />"
    body.append "<target />"
    body.append "<target />"

    targets = $("target")
    @t1 = targets[0]
    @t2 = targets[1]
    @t3 = targets[2]

    @t1.getBoundingClientRect = ->
      ClientRect.new width: 100, height: 50

    @t2.getBoundingClientRect = ->
      ClientRect.new top: 50, width: 100, height: 50

    @t3.getBoundingClientRect = ->
      ClientRect.new top: 100, width: 100, height: 50

  teardown: ->
    $("target").remove()

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
    Taxi.Governer.exit()

test "dropstart triggers dropstart event if current hit has a rect", ->
    targets = NS.SomeTargets.new()
    hit = rect: true
    targets.currentHit = hit
    expect 1
    targets.bind "dropstart", (thehit) -> equal hit, thehit
    targets.dropstart()
    Taxi.Governer.exit()

test "dropstart is a noop if current hit lacks a rect", ->
    targets = NS.SomeTargets.new()
    expect 0
    targets.bind "dropstart", -> ok true
    targets.dropstart()

test "dragend calls drop and triggers drop if current hit has a rect", ->
    targets = NS.SomeTargets.new()
    hit = rect: true
    data = new Object
    targets.currentHit = hit
    expect 2
    targets.bind "drop", (thehit) -> equal hit, thehit
    targets.drop = (thedata) -> equal thedata, data
    targets.dragend(data)
    Taxi.Governer.exit()

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
      targets.transitionHit {}

test "noop if currenth hit equals hit", ->
      targets = NS.SomeTargets.new()
      targets.currentHit = equals: -> true
      targets.dropend = -> ok true
      expect 0
      targets.transitionHit {}

test "transitions if current hit does not equal hit", ->
      targets = NS.SomeTargets.new()
      targets.currentHit = equals: -> false
      hit = rect: true
      expect 2
      targets.dropend = ->
        ok targets.currentHit isnt hit
      targets.dropstart = ->
        ok targets.currentHit is hit
      targets.transitionHit hit


targetEvent = (x, y) ->
  return {
      "jquery/event": originalEvent:
        clientX: x
        clientY: y
  }


setupEdgeTargets = ->
  @targets = AS.Models.Targets.Edge.new()
  @el = {}
  @rect = ClientRect.new width: 100, height: 50
  @targets.targets = [
    el: @el
    rect: @rect
  ]

module "Targets.Edge.verticalTarget",
  setup: ->
    setupEdgeTargets.call(this)
    @check = (x, y) =>
      @targets.verticalTarget targetEvent(x, y)

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

module "Targets.Edge.horizontalTarget",
  setup: ->
    setupEdgeTargets.call(this)
    @check = (x, y) =>
      @targets.horizontalTarget targetEvent(x, y)

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
    @rect = ClientRect.new width: 100, height: 50
    @targets.targets = [
      el: @el
      rect: @rect
    ]

    @check = (x, y) =>
      @targets.target targetEvent(x, y)

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


