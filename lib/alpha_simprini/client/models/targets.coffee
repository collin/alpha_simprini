AS = require("alpha_simprini")
$ = require("jquery")
Taxi = require "taxi"

TOP = name:"TOP"
MIDDLE = name:"MIDDLE"
BOTTOM = name:"BOTTOM"
LEFT = name: "LEFT"
RIGHT = name: "RIGHT"

AS.Models.Targets = AS.Object.extend ({def, defs, include}) ->
  include Taxi.Mixin
  def TOP: TOP
  def MIDDLE: MIDDLE
  def BOTTOM: BOTTOM
  def LEFT: LEFT
  def RIGHT: RIGHT

  def initialize: ->
    @gather()

  def gather: ->
    @targets = $(@selector).map (i, el) ->
      return el: $(el), rect: el.getBoundingClientRect()

  def validate: () -> true
  # validate: (data) -> true
  #   return @element().can_be_parent_for(data.source)

  def dropstart: () ->
    return unless @current_hit?.rect
    @trigger("dropstart", @current_hit)

  def dropend: () ->
    @trigger("dropend")

  def drop: (event) ->

  def dragend: (event) ->
    return unless @current_hit?.rect
    @drop(event)
    @trigger("drop", @current_hit)

  def transition_hit: (hit) ->
    return @dropend() if hit is null
    @current_hit ?= AS.Models.Targets.Hit.new()
    # Nothin' changed, eh?
    return if @current_hit.equals(hit) or hit.rect is undefined
    @dropend()
    @current_hit = hit
    @dropstart()

  def drag: (event) ->
    throw "Drag unimplimented in base class!"

AS.Models.Targets.TOP = TOP
AS.Models.Targets.MIDDLE = MIDDLE
AS.Models.Targets.BOTTOM = BOTTOM
AS.Models.Targets.LEFT = LEFT
AS.Models.Targets.RIGHT = RIGHT

AS.Models.Targets.Edge = AS.Models.Targets.extend ({def}) ->
  def initialize: (options={}) ->
    @_super()
    @edge = options.edge or 30

  def horizontal_target: (event) ->
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
    return AS.Models.Targets.Hit.new target.rect, target.el, edge


  def vertical_target: (event) ->
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
    return AS.Models.Targets.Hit.new target.rect, target.el, edge


AS.Models.Targets.Thirds = AS.Models.Targets.extend ({def}) ->

  def within_vertically: (y, rect) ->
    rect.top <= y <= rect.bottom

  def which_third: (y, rect) ->
    # pre-supposes within_vertically is true
    one_third = rect.height / 3
    offset = y - rect.top

    if offset <= one_third
      @TOP
    else if offset <= one_third * 2
      @MIDDLE
    else
      @BOTTOM

  def target: (event) ->
    {clientY} = event["jquery/event"].originalEvent
    for target in @targets
      if @within_vertically(clientY, target.rect)
        hit = AS.Models.Targets.Hit.new(target.rect, target.el, @which_third(clientY, target.rect), event)
        return hit if @validate(hit)
    return null

  def drag: (event) ->
    @transition_hit @target(event)

AS.Models.Targets.Hit = AS.Object.extend ({def}) ->
  def TOP: TOP
  def MIDDLE: MIDDLE
  def BOTTOM: BOTTOM
  def LEFT: LEFT
  def RIGHT: RIGHT
  def initialize: (@rect=null, @el=null, @section=null, @event) ->
  def equals: (other=AS.Models.Targets.Hit.new()) ->
    other.el is @el and other.section is @section

