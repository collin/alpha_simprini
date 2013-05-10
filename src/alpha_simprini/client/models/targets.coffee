TOP = name:"TOP", toString: -> @name
MIDDLE = name:"MIDDLE", toString: -> @name
BOTTOM = name:"BOTTOM", toString: -> @name
LEFT = name: "LEFT", toString: -> @name
RIGHT = name: "RIGHT", toString: -> @name
WITHIN = name: "WITHIN", toString: -> @name

class AS.Models.Targets
  include Taxi.Mixin
  def TOP: TOP
  def MIDDLE: MIDDLE
  def BOTTOM: BOTTOM
  def LEFT: LEFT
  def RIGHT: RIGHT
  def WITHIN: WITHIN

  def initialize: (@application) ->
    @gather()
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def gather: ->
    @targets = $(@selector, @application?.el).map (i, el) ->
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
    @trigger("drop")
  # @::drop.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def dragend: (event) ->
    return unless @currentHit?.rect
    # @drop(event) #trigger twice? :(
    @currentHit.el.closest(".View").data('view').trigger("drop", event, @currentHit)
    @trigger("drop", event, @currentHit)
  # @::dragend.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def transitionHit: (hit) ->
    if hit is null
      @currentHit = undefined
      return @dropend() 
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

  def withinVertically: (y, rect) ->
    rect.top <= y <= rect.bottom
  # @::withinVertically.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def withinHorizontally: (x, rect) ->
    rect.left <= x <= rect.right
  # @::withinVertically.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #     Runs in two passes. First pass finds matches.
  #     Second pass 
  #   """

  withinRect = (other) ->
    @left > other.left &&
    @right < other.right &&
    @top > other.top &&
    @bottom < other.bottom
    
  def target: (event) ->
    {clientX, clientY} = event["jquery/event"].originalEvent
    bestMatch = null
    for target in @targets
      continue unless @withinVertically(clientY, target.rect)
      continue unless @withinHorizontally(clientX, target.rect)
      unless bestMatch
        bestMatch = target
        continue

      bestMatch = target if withinRect.call(target.rect, bestMatch.rect)

    return null unless bestMatch
    hit = AS.Models.Targets.Hit.new(bestMatch.rect, bestMatch.el, WITHIN, event)
    return hit if @validate(hit)
    return null


  def drag: (event) ->
    @transitionHit @target(event)
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
AS.Models.Targets.WITHIN = WITHIN

class AS.Models.Targets.Edge < AS.Models.Targets
  
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


class AS.Models.Targets.Thirds < AS.Models.Targets

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


class AS.Models.Targets.Hit
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
