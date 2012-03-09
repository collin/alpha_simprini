AS = require("alpha_simprini")
$ = require("jquery")

TOP = name:"TOP"
MIDDLE = name:"MIDDLE"
BOTTOM = name:"BOTTOM"
LEFT = name: "LEFT"
RIGHT = name: "RIGHT"

AS.Models.Targets = AS.Object.extend
  TOP: TOP
  MIDDLE: MIDDLE
  BOTTOM: BOTTOM
  LEFT: LEFT
  RIGHT: RIGHT

  constructor: ->
    @gather()

  gather: ->
    @targets = $(@selector).map (i, el) ->
      return el: $(el), rect: el.getBoundingClientRect()

  validate: () -> true
  # validate: (data) -> true
  #   return @element().can_be_parent_for(data.source)

  dropstart: () ->
    return unless @current_hit?.rect
    @trigger("dropstart", @current_hit)

  dropend: () ->
    @trigger("dropend")

  drop: (event) ->

  dragend: (event) ->
    return unless @current_hit?.rect
    @drop(event)
    @trigger("drop", @current_hit)

  transition_hit: (hit) ->
    return @dropend() if hit is null
    @current_hit ?= new AS.Models.Targets.Hit
    # Nothin' changed, eh?
    return if @current_hit.equals(hit) or hit.rect is undefined
    @dropend()
    @current_hit = hit
    @dropstart()

  drag: (event) ->
    throw "Drag unimplimented in base class!"

AS.Models.Targets.TOP = TOP
AS.Models.Targets.MIDDLE = MIDDLE
AS.Models.Targets.BOTTOM = BOTTOM
AS.Models.Targets.LEFT = LEFT
AS.Models.Targets.RIGHT = RIGHT

class AS.Models.Targets.Edge extends AS.Models.Targets
  constructor: (options={}) ->
    super
    @edge = options.edge or 30

  horizontal_target: (event) ->
    {clientX, clientY} = event["jquery/event"].originalEvent
    for target in @targets
      rect = target.rect
      withinX = rect.left - @edge <= clientX <= rect.right + @edge
      withinY = rect.top <= clientY <= rect.bottom
      continue unless withinX and withinY

      edge = if rect.left - @edge <= clientX <= rect.left + @edge
        @LEFT
      else if rect.left + @edge <= clientX >= rect.right - @edge
        @RIGHT
      break

    return null unless edge
    return new AS.Models.Targets.Hit target.rect, target.el, edge


  vertical_target: (event) ->
    {clientX, clientY} = event["jquery/event"].originalEvent

    for target in @targets
      rect = target.rect
      withinX = rect.left <= clientX <= rect.right
      withinY = rect.top - @edge <= clientY <= rect.bottom + @edge
      continue unless withinX and withinY

      edge = if rect.top - @edge <= clientY <= rect.top + @edge
        @TOP
      else if rect.bottom - @edge <= clientY <= rect.bottom + @edge
        @BOTTOM
      break

    return null unless edge
    return new AS.Models.Targets.Hit target.rect, target.el, edge


class AS.Models.Targets.Thirds extends AS.Models.Targets

  within_vertically: (y, rect) ->
    rect.top <= y <= rect.bottom

  which_third: (y, rect) ->
    # pre-supposes within_vertically is true
    one_third = rect.height / 3
    offset = y - rect.top

    if offset <= one_third
      @TOP
    else if offset <= one_third * 2
      @MIDDLE
    else
      @BOTTOM

  target: (event) ->
    {clientY} = event["jquery/event"].originalEvent
    for target in @targets
      if @within_vertically(clientY, target.rect)
        hit = new AS.Models.Targets.Hit(target.rect, target.el, @which_third(clientY, target.rect), event)
        return hit if @validate(hit)
    return null

  drag: (event) ->
    @transition_hit @target(event)

class AS.Models.Targets.Hit
  TOP: TOP
  MIDDLE: MIDDLE
  BOTTOM: BOTTOM
  LEFT: LEFT
  RIGHT: RIGHT
  constructor: (@rect=null, @el=null, @section=null, @event) ->
  equals: (other=new AS.Models.Targets.Hit) ->
    other.el is @el and other.section is @section

