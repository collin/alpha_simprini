AS = require("alpha_simprini")
$ = require("jquery")

TOP = name:"TOP"
MIDDLE = name:"MIDDLE"
BOTTOM = name:"BOTTOM"
LEFT = name: "LEFT"
RIGHT = name: "RIGHT"

class AS.Models.Targets
  AS.Event.extends(this)
  TOP: TOP
  MIDDLE: MIDDLE
  BOTTOM: BOTTOM
  LEFT: LEFT
  RIGHT: RIGHT

  constructor: ->
    @targets = $ []

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

  drop: () ->

  dragend: (data) ->
    return unless @current_hit?.rect
    @drop(data)
    @trigger("drop", @current_hit)

  transition_hit: (hit) ->
    @current_hit ?= new AS.Models.Targets.Hit
    # Nothin' changed, eh?
    return if @current_hit.equals(hit) or hit.rect is undefined
    @dropend()
    @current_hit = hit
    @dropstart()

  drag: (data) ->
    throw "Drag unimplimented in base class!"

class AS.Models.Targets.Edge extends AS.Models.Targets
  constructor: (options={}) ->
    super
    @edge = options.edge or 30

  horizontal_target: (event) ->
    {clientX, clientY} = event["jquery/event"].originalEvent
    for target in @targets
      rect = target.rect
      withinX = rect.left - @edge < clientX < rect.right + @edge
      withinY = rect.top < clientY <= rect.bottom
      continue unless withinX and withinY

      edge = if rect.left - @edge < clientX < rect.left + @edge
        @LEFT
      else if rect.left + @edge < clientX > rect.right - @edge
        @RIGHT
      break

    return null unless edge
    return new AS.Models.Targets.Hit target.rect, target.el, edge


  vertical_target: (event) ->
    {clientX, clientY} = event["jquery/event"].originalEvent

    for target in @targets
      rect = target.rect
      withinX = rect.left - @edge < clientX < rect.right + @edge
      withinY = rect.top - @edge < clientY < rect.bottom + @edge
      continue unless withinX and withinY

      edge = if rect.top - @edge < clientY < rect.top + @edge
        @TOP
      else if rect.bottom - @edge < clientY < rect.bottom + @edge
        @BOTTOM
      break

    return null unless edge
    return new AS.Models.Targets.Hit target.rect, target.el, edge


class AS.Models.Targets.Thirds extends AS.Models.Targets

  within_vertically: (y, rect) ->
    rect.top < y < rect.bottom

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
    console.log "TARGET"
    {clientY} = event["jquery/event"].originalEvent
    for target in @targets
      if @within_vertically(clientY, target.rect)
        hit = new AS.Models.Targets.Hit(target.rect, target.el, @which_third(clientY, target.rect), event)
        return hit if @validate(hit)
    return new AS.Models.Targets.Hit

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

