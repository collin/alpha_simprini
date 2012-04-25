AS.ViewEvents = AS.Object.extend ({def}) ->
  EVENT_SPLITTER = /^(@?[\w:]+)\s*(.*)$/

  def initialize: (@view, events) ->
    @namespace = _.uniqueId ".ve"
    @events = @unifyOptions(events)
    @validateOptions()
    @cacheHandlers()

  def unifyOptions: (events) ->
    for key, options of events
      if _.isString options
        options = events[key] = methodName: options

      [__, eventName, selector] = key.match EVENT_SPLITTER

      options.eventName = eventName + @namespace
      options.selector = selector
      options.method = @view[options.methodName]


    return events

  def validateOptions: ->
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
        Do you need to define the method: `#{options.methodName}'?
        """

      if options.method and !_.isFunction(options.method)
        console.error options.method, "was given instead of a function."
        throw new Error """
        Event Binding Error in #{@view.constructor.name}!
        Specified method for event #{key} that is not a function.
        Specify only a function as a method for an event handler.
        """

  def cacheHandlers: ->
    for key, options of @events
      do (key, options) =>
        options.handler = (_, event) =>

          if options.method
            options.method.apply(@view, arguments)
          else if options.transition
            @view.transitionState options.transition

  def revokeBindings: ->
    @revokeBinding(options) for key, options of @events

  def revokeBinding: (options) ->
    [selector, eventName] = [options.selector, options.eventName]
    if selector is ''
      @view.el.unbind @namespace
    else if selector is '@'
      @view.unbind @namespace
    else if selector[0] is '@'
      @view[selector.slice(1)]?.unbind @namespace
    else
      target = @view.$(selector, @view.el[0])
      target.off @namespace
      target.click() # bug with drag/drop allows for one last drag after revoking bindings :(

  def applyBindings: ->
    @applyBinding(options) for key, options of @events

  def applyBinding: (options) ->
    [selector, eventName, handler] = [options.selector, options.eventName, options.handler]
    if selector is ''
      @view.el.bind eventName, handler
    else if selector is '@'
      @view.bind eventName, handler, @view
    else if selector[0] is '@'
      emitter = @view[selector.slice(1)]
      if emitter is undefined
        AS.error "Attempted to bind to #{selector}, no such member on #{this}"
      if emitter instanceof AS.ViewModel
        emitter.model?.bind eventName, handler, @view
      else
        emitter.bind eventName, handler, @view
    else
      selector = selector.replace /\$/g, "#"+@view.el.attr('id')
      @view.el.delegate selector, eventName, handler
