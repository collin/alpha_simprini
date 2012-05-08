TOP = name:"TOP", toString: -> @name
MIDDLE = name:"MIDDLE", toString: -> @name
BOTTOM = name:"BOTTOM", toString: -> @name
LEFT = name: "LEFT", toString: -> @name
RIGHT = name: "RIGHT", toString: -> @name

AS.Models.Targets = AS.Object.extend ({def, defs, include}) ->
  include Taxi.Mixin
  def TOP: TOP
  def MIDDLE: MIDDLE
  def BOTTOM: BOTTOM
  def LEFT: LEFT
  def RIGHT: RIGHT

  def initialize: ->
    @gather()
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def gather: ->
    @targets = $(@selector).map (i, el) ->
      return el: $(el), rect: el.getBoundingClientRect()
  # @::gather.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def validate: () -> true
  # @::validate.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def dropstart: () ->
    return unless @currentHit?.rect
    @trigger("dropstart", @currentHit)
  # @::dropstart.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def dropend: () ->
    @trigger("dropend")
  # @::dropend.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def drop: (event) ->
  # @::drop.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def dragend: (event) ->
    return unless @currentHit?.rect
    @drop(event)
    @trigger("drop", @currentHit)
  # @::dragend.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def transitionHit: (hit) ->
    return @dropend() if hit is null
    @currentHit ?= AS.Models.Targets.Hit.new()
    # Nothin' changed, eh?
    return if @currentHit.equals(hit) or hit.rect is undefined
    @dropend()
    @currentHit = hit
    @dropstart()
  # @::transitionHit.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def drag: (event) ->
    throw "Drag unimplimented in base class!"
  # @::drag.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

AS.Models.Targets.TOP = TOP
AS.Models.Targets.MIDDLE = MIDDLE
AS.Models.Targets.BOTTOM = BOTTOM
AS.Models.Targets.LEFT = LEFT
AS.Models.Targets.RIGHT = RIGHT

AS.Models.Targets.Edge = AS.Models.Targets.extend ({def}) ->
  def initialize: (options={}) ->
    @_super()
    @edge = options.edge or 30
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def horizontalTarget: (event) ->
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
  # @::horizontalTarget.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def verticalTarget: (event) ->
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
  # @::verticalTarget.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

AS.Models.Targets.Thirds = AS.Models.Targets.extend ({def}) ->

  def withinVertically: (y, rect) ->
    rect.top <= y <= rect.bottom
  # @::withinVertically.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def whichThird: (y, rect) ->
    # pre-supposes withinVertically is true
    oneThird = rect.height / 3
    offset = y - rect.top

    if offset <= oneThird
      @TOP
    else if offset <= oneThird * 2
      @MIDDLE
    else
      @BOTTOM
  # @::whichThird.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def target: (event) ->
    {clientY} = event["jquery/event"].originalEvent
    for target in @targets
      if @withinVertically(clientY, target.rect)
        hit = AS.Models.Targets.Hit.new(target.rect, target.el, @whichThird(clientY, target.rect), event)
        return hit if @validate(hit)
    return null
  # @::target.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def drag: (event) ->
    @transitionHit @target(event)
  # @::drag.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

AS.Models.Targets.Hit = AS.Object.extend ({def}) ->
  def TOP: TOP
  def MIDDLE: MIDDLE
  def BOTTOM: BOTTOM
  def LEFT: LEFT
  def RIGHT: RIGHT
  def initialize: (@rect=null, @el=null, @section=null, @event) ->
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
  def equals: (other=AS.Models.Targets.Hit.new()) ->
    other.el is @el and other.section is @section
  # @::equals.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

