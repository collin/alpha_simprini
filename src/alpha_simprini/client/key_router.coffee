{each} = _


class AS.KeyRouter
  def initialize: (@target, source) ->
    @reroute(source)
  # @::initialize.doc = 
  #   params: [
  #     ["@target", "AS.Application", true, tag: "Application that key events will be triggered on."]
  #     ["@source", "HTMLElement", true, tag: "Source of keyboard events."]
  #   ]
  #   desc: """
  #     
  #   """ 

  def reroute: (newSource) ->
    @source?.unbind(".#{@objectId()}")
    @source = $(newSource)
    @registerHandlers()
  # @::reroute.doc = 
  #   params: [
  #     ["@source", "HTMLElement", true, tag: "Source of keyboard events."]
  #   ]
  #   desc: """
  #     Re-route keyboard events to a new application.
  #   """
    
  def registerHandlers: ->
    handlers =
      '⎋': 'escape'
      '⌘+↩': 'accept'
      'backspace': 'delete'
      "↩": "open"
      "up": "up"
      "down": "down"
      "home": "first"
      "end": "last"
      "left": "left"
      "right": "right"
      "tab": "indent"
      "shift+tab": "dedent"
      "[a-z]/[0-9]/shift+[a-z]": "alphanum"

    each handlers, (trigger, key) =>
      # console.log trigger, key
      @source.on "keydown.#{@objectId()}", jwerty.event(key, (event) =>
        # console.log "KEY", trigger, @target.toString()
        @target.trigger(trigger, event)
      )

      @source.on "keydown.#{@objectId()}", jwerty.event("backspace", (event) =>
        @target.trigger("delete", event)
      )
  # @::registerHandlers.doc =
  #   desc: """
  #     Binds the standard key handlers for an Alpha Simprini application.
  #   """
