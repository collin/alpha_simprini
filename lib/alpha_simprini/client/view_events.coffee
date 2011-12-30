AS = require("alpha_simprini")
_ = require "underscore"

class AS.ViewEvents
  EVENT_SPLITTER = /^(@?[\w:]+)(\{.*\})?\s*(.*)$/

  PARSE_GUARD = (guard="{}") ->
    guard = guard.replace(/(\w+):/g, (__, match) -> "\"#{match}\":")
    guard = JSON.parse(guard)
    
  
  constructor: (@view, events) ->
    @namespace = _.uniqueId ".ve"
    @events = @unify_options(events)
    @validate_options()
    @cache_handlers()
    
  unify_options: (events) ->
    for key, options of events
      if _.isString options
        options = events[key] = method_name: options
      
      [__, event_name, guard, selector] = key.match EVENT_SPLITTER
      
      options.event_name = event_name + @namespace
      options.guard = PARSE_GUARD(guard)
      options.selector = selector
      options.method = @view[options.method_name]
      

    return events

  validate_options: ->
    for key, options of @events
      if options.method and options.transition
        throw new Error """
        Event Binding Error in #{@view.constructor.name}!
        Specified both method and transition for event #{key}.
        Use before/after hooks for transitions instead.
        """
  
      if !options.method and !options.transition
        throw new Error """
        Event Binding Error in #{@view.constructor.name}!
        Specified neither method or transition for event #{key}.
        Specify what to do when handling this error.
        Do you need to define the method: `#{options.method_name}'?
        """
      
      if options.method and !_.isFunction(options.method)
        console.error options.method, "was given instead of a function."
        throw new Error """
        Event Binding Error in #{@view.constructor.name}!
        Specified method for event #{key} that is not a function.
        Specify only a function as a method for an event handler.
        """
        
  cache_handlers: ->
    for key, options of @events
      do (key, options) =>
        options.handler = (event) =>
          for key, value of options.guard 
            return unless event[key] is value
    
          if options.method
            options.method.apply(@view, arguments)
          else if options.transition
            @view.transition_state options.transition
  
  revoke_bindings: ->
    @revoke_binding(options) for key, options of @events
  
  revoke_binding: (options) ->
    [selector, event_name] = [options.selector, options.event_name]
    if selector is ''
      @view.el.unbind @namespace
    else if selector is '@'
      @view.unbind @namespace
    else if selector[0] is '@'
      @view[selector.slice(1)]?.unbind @namespace
    else
      target = @view.$(selector, @view.el[0])
      target.die @namespace
      target.click() # bug with drag/drop allows for one last drag after revoking bindings :(
  
  apply_bindings: ->
    @apply_binding(options) for key, options of @events
    
  apply_binding: (options) ->
    [selector, event_name, handler] = [options.selector, options.event_name, options.handler]
    if selector is ''
      @view.el.bind event_name, handler
    else if selector is '@'
      @view.bind event_name, handler, @view
    else if selector[0] is '@'
      emitter = @view[selector.slice(1)]
      if emitter is undefined
        AS.error "Attempted to bind to #{selector}, no such member on #{this}"
      if emitter instanceof AS.ViewModel
        emitter.model?.bind event_name, handler, @view
      else
        emitter.bind event_name, handler, @view
    else
      @view.$(selector, @view.el[0]).live event_name, handler
