AS = require("alpha_simprini")
_ = require "underscore"

AS.ViewEvents = AS.Object.extend ({def}) ->
  EVENT_SPLITTER = /^(@?[\w:]+)\s*(.*)$/

  def initialize: (@view, events) ->
    @namespace = _.uniqueId ".ve"
    @events = @unify_options(events)
    @validate_options()
    @cache_handlers()

  def unify_options: (events) ->
    for key, options of events
      if _.isString options
        options = events[key] = method_name: options

      [__, event_name, selector] = key.match EVENT_SPLITTER

      options.event_name = event_name + @namespace
      options.selector = selector
      options.method = @view[options.method_name]


    return events

  def validate_options: ->
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

  def cache_handlers: ->
    for key, options of @events
      do (key, options) =>
        options.handler = (_, event) =>

          if options.method
            options.method.apply(@view, arguments)
          else if options.transition
            @view.transition_state options.transition

  def revoke_bindings: ->
    @revoke_binding(options) for key, options of @events

  def revoke_binding: (options) ->
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

  def apply_bindings: ->
    @apply_binding(options) for key, options of @events

  def apply_binding: (options) ->
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
      @view.el.delegate selector, event_name, handler
