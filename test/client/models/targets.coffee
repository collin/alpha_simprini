{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")

class SomeTargets extends AS.Models.Targets
  selector: "target"

class ClientRect
  top: 0
  left: 0
  width: 0
  height: 0

  constructor: (properties) ->
    require("underscore").extend(this, properties)
    @right = @left + @width
    @bottom = @top + @height

exports.Targets =
  setUp: (callback) ->
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

    callback()

  "gathers targets": (test) ->
    targets = (new SomeTargets).targets
    test.equal targets.length, 3
    test.equal targets[1].el[0], @t2
    test.equal targets[1].rect.top, 50, 'top'
    test.equal targets[1].rect.right, 100, 'right'
    test.equal targets[1].rect.bottom, 100, 'bottom'
    test.equal targets[1].rect.left, 0, 'left'
    test.equal targets[1].rect.width, 100, 'width'
    test.equal targets[1].rect.height, 50, 'height'
    test.done()

  "dropend triggers dropend event": (test) ->
    targets = new SomeTargets
    test.expect 1
    targets.bind "dropend", -> test.ok true
    targets.dropend()
    test.done()

  "dropstart triggers dropstart event if current hit has a rect": (test) ->
    targets = new SomeTargets
    hit = rect: true
    targets.current_hit = hit
    test.expect 1
    targets.bind "dropstart", (thehit) -> test.equal hit, thehit
    targets.dropstart()
    test.done()

  "dropstart is a noop if current hit lacks a rect": (test) ->
    targets = new SomeTargets
    test.expect 0
    targets.bind "dropstart", -> test.ok true
    targets.dropstart()
    test.done()

  "dragend calls drop and triggers drop if current hit has a rect": (test) ->
    targets = new SomeTargets
    hit = rect: true
    data = new Object
    targets.current_hit = hit
    test.expect 2
    targets.bind "drop", (thehit) -> test.equal hit, thehit
    targets.drop = (thedata) -> test.equal thedata, data
    targets.dragend(data)
    test.done()

  "dragend is a noop if current hit lacks a rect": (test) ->
    targets = new SomeTargets
    data = new Object
    test.expect 0
    targets.bind "drop", (thehit) -> test.equal hit, thehit
    targets.drop = (thedata) -> test.equal thedata, data
    targets.dragend(data)
    test.done()

  "transition_hit()":
    "noop if hit has no rect": (test) ->
      targets = new SomeTargets
      targets.dropend = -> test.ok true
      test.expect 0
      targets.transition_hit {}
      test.done()

    "noop if currenth hit equals hit": (test) ->
      targets = new SomeTargets
      targets.current_hit = equals: -> true
      targets.dropend = -> test.ok true
      test.expect 0
      targets.transition_hit {}
      test.done()

    "transitions if current hit does not equal hit": (test) ->
      targets = new SomeTargets
      targets.current_hit = equals: -> false
      hit = rect: true
      test.expect 2
      targets.dropend = ->
        test.ok targets.current_hit isnt hit
      targets.dropstart = ->
        test.ok targets.current_hit is hit
      targets.transition_hit hit
      test.done()


target_event = (x, y) ->
  return {
    "jquery/event": originalEvent:
      clientX: x, clientY: y
  }

exports.Targets.Edge =
  setUp: (callback) ->
    @targets = new AS.Models.Targets.Edge
    @el = {}
    @rect = new ClientRect width: 100, height: 50
    @targets.targets = [
      el: @el
      rect: @rect
    ]
    callback()

  "vertical_target":
    setUp: (callback) ->
      @check = (x, y) =>
        @targets.vertical_target target_event(x, y)
      callback()

    "misses when not inside box": (test) ->
      test.equal null, @check(-1, -1), "before"
      test.equal null, @check(101, 51), "after"
      test.equal null, @check(70, 101), "inside x, outside y"
      test.equal null, @check(50, 130), "outside x, inside y"
      test.done()

    "hits when inside the box": (test) ->
      test.ok @check(100, 80), "within edge x, inside y"
      test.ok @check(0, -30), "within edge x, inside y"
      test.done()

    "hits TOP/BOTTOM": (test) ->
      hit = @check(0, 0)
      test.equal hit.section, hit.TOP

      hit = @check(0, 50)
      test.equal hit.section, hit.BOTTOM
      test.done()

  "horizontal_target":
    setUp: (callback) ->
      @check = (x, y) =>
        @targets.horizontal_target target_event(x, y)
      callback()

    "misses when not inside box": (test) ->
      test.equal null, @check(-1, -1), "before"
      test.equal null, @check(101, 51), "after"
      test.equal null, @check(70, 101), "outside x, inside y"
      test.equal null, @check(50, 50), "inside x, outside y"
      test.done()

    "hits when inside the box": (test) ->
      test.ok @check(130, 50), "within x, inside edge y"
      test.ok @check(-30, 0), "within x, inside edge y"
      test.done()

    "hits LEFT/RIGHT": (test) ->
      hit = @check(0, 0)
      test.equal hit.section, hit.LEFT

      hit = @check(100, 0)
      test.equal hit.section, hit.RIGHT

      test.done()

exports.Targets.Thirds =
  setUp: (callback) ->
    @targets = new AS.Models.Targets.Thirds
    @el = {}
    @rect = new ClientRect width: 100, height: 50
    @targets.targets = [
      el: @el
      rect: @rect
    ]

    @check = (x, y) =>
      @targets.target target_event(x, y)
    callback()


  "misses when not inside vertically": (test) ->
    test.equal null, @check(0, -1), "before"
    test.equal null, @check(0, 51), "after"
    test.done()

  "hits TOP/MIDDLE/BOTTOM": (test) ->
    hit = @check(0, 0)
    test.equal hit.section, hit.TOP

    hit = @check(0, 25)
    test.equal hit.section, hit.MIDDLE

    hit = @check(0, 50)
    test.equal hit.section, hit.BOTTOM

    test.done()

