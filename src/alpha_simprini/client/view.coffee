AS.part("Core")
AS.Core.require("callbacks")

class AS.View < AS.DOM
  include Taxi.Mixin
  include AS.Callbacks

  @defineCallbacks after: ['content'], before: ['content']

  delegate 'addClass', 'removeClass', 'show', 'hide', 'html', 'find', to: "el"

  def tagName: "div"

  def attrBindings: null

  def _ensureElement: ->
    @el ?= @$(@buildElement())
    baseAttributes = @baseAttributes()
    baseAttributes["class"] = undefined if @el.attr("class")
    baseAttributes["id"] = undefined if @el.attr("id")
    @el.attr(baseAttributes)
  # @::_ensureElement.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def initialize: (config={}) ->
    config.el = @$(config.el) if config.el and !(config.el.jquery)

    @cid = _.uniqueId("c")

    for key, value of config
      if value?.model instanceof AS.Model
        @[key] = AS.ViewModel.build(this, value.model)
      else
        @[key] = value

    @childViews = []

    @bindingGroup = AS.BindingGroup.new(@parentVew?.bindingGroup)
    @_ensureElement()
    @currentNode = @el[0]

    @runCallbacks "beforeContent"
    @content()
    @delegateEvents()
    @bindAttrs()
    @runCallbacks "afterContent"
    @el.data().view = this

  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def content: ->
    # Make your content here.
  # @::content.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def append: (view) -> @el.append view.el
  # @::append.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def processAttr: (node, key, value) ->
  #   if value instanceof Function
  #     # switch value
  #     # when AS.Binding.Field
  #     #   false
  #     # else
  #     #   false
  #   else
    node.setAttribute(key, value)
  # @::processAttr.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def groupBindings: (fn) ->
    @withinBindingGroup @bindingGroup.addChild(), fn
  # @::groupBindings.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def withinBindingGroup: (bindingGroup, fn) ->
    currentGroup = @bindingGroup
    @bindingGroup = bindingGroup
    content = fn.call(this, bindingGroup)
    @bindingGroup = currentGroup
    content
  # @::withinBindingGroup.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def binds: -> @bindingGroup.binds.apply(@bindingGroup, arguments)
  # @::binds.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def klassString: ->
    classes = []
    for ancestor in @constructor.ancestors
      continue unless ancestor.path().match(/Views?/)
      classes.push ancestor._name()

    classes.join(" ")
  # @::klassString.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def baseAttributes: ->
    attrs =
      class: @klassString()
      id: @objectId()
  # @::baseAttributes.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def buildElement: ->
    @currentNode = @[@tagName]()
  # @::buildElement.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def view: (constructor, options={}) ->
    options.application = @application
    options.parentView = this
    view = constructor.new(options)  
    @[options.name] = view if options.name
    @childViews.push(view)
    @bindingGroup.addChild(view)
    @currentNode?.appendChild view.el[0] unless view.el.parent().is("*")
    view.el[0]
  # @::view.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #     <dl>
  #       <dt> name
  #       <dd> If name option is given the child view will be set as a property
  #            on the parent view.
  #   """

  def descendantViews: (views=[], constructor) ->
    for view in @childViews
      if constructor
        views.push view if view instanceof constructor
      else
        views.push view
      view.descendantViews(views, constructor)

    views
  # @::descendantViews.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def removeChild: (child) ->
    @childViews = _.without(@childViews, child)
  # @::removeChild.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  # DO NOT OVERRIDE #unbind
  # find out why, AND MENTION IT HERE
  # because ANY event unbinding will remove the child view
  def unbind: ->
    # AS.warn("Do not OVERRIDE View.unbind")
    @_super.apply(this, arguments)
  # @::unbind.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def binding: (bindable, options, fnOrElement) ->
    if fnOrElement is undefined and _.isFunction(options)
      fnOrElement = options
      options = {}

    if _.include(fnOrElement?.ancestors, AS.View)
      @binding bindable, options, (model) -> 
        options.model = model
        @view fnOrElement, options
    else if bindable instanceof AS.Collection or bindable instanceof AS.Model.HasMany.Instance
      AS.Binding.Many.new(this, bindable, bindable, options, fnOrElement)
    else if bindable instanceof AS.Model
      AS.Binding.Model.new(this, bindable, options or fnOrElement)
    else if _.isString(bindable) and @model?[bindable]
      @model.binding(bindable, options, fnOrElement)
    else if _.isString(bindable) and @[bindable]
      @binding @[bindable], options, fnOrElement
  # @::binding.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def modelBinding: ->
    @_modelBinding ?= AS.Binding.Model.new(this, @model, @el)
  # @::modelBinding.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def bindAttrs: ->
    return unless @attrBindings
    @modelBinding().attr @attrBindings
    @modelBinding().paint()
  # @::bindAttrs.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def delegateEvents: () ->
    @stateStates = AS.Map.new()

    if @events
      @standardEvents = AS.ViewEvents.new(this, @events)
      @standardEvents.applyBindings()

    stateEvents = _(@constructor::).chain().keys().filter( (key) -> key.match(/Events$/)? )
    @stateEvents = {}
    for key in stateEvents.value()
      state = key.replace(/Events$/, '')
      do (key, state) =>
        @stateEvents[state] = AS.ViewEvents.new(this, @[key])

        @["exit_#{state}"] = ->
          if @stateStates.get(state) is false
            throw "Cannot exit a state before entering it: #{state}"
          @trigger("exitstate:#{state}")
          @stateEvents[state].revokeBindings()
          @stateStates.set(state, false)

        @["enter_#{state}"] = ->
          if @stateStates.get(state) is true
            throw "Cannot re-enter a state: #{state}"
          @stateStates.set(state, true)
          @trigger("enterstate:#{state}")
          @stateEvents[state].applyBindings()
  # @::delegateEvents.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def enterState: (stateName) ->
    @["enter_#{stateName}"]()
  # @::enterState.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def exitState: (stateName) ->
    @["exit_#{stateName}"]()
  # @::exitState.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  # TODO: put these into modules or something.
  def pluralize: (thing, count) ->
    if count in [-1, 1]
      fleck.singularize(thing)
    else
      fleck.pluralize(thing)

  # @::pluralize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def resetCycle: (args...) ->
    delete @_cycles[args.join()] if @_cycles
  # @::resetCycle.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def cycle: (args...) ->
    @_cycles ?= {}
    @_cycles[args.join()] ?= 0
    count = @_cycles[args.join()] += 1
    args[count % args.length]
  # @::cycle.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  mergeViewOptions = (left, right) ->
    for key, value of right
      if left[key]
        switch key
          when 'class'
            left[key] += " " + value
          else
            left[key] = value
      else
        left[key] = value

  def toggle: ->
    @button class:"toggle expand"
    @button class:"toggle collapse"
  # @::toggle.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def icon: (name, options={}) ->
    if options.class
      options.class = "#{options.class} icon-#{name}"
    else
      options.class = "icon-#{name}"  
    @i options
  # @::icon.doc = 
  #   params: [
  #     ["name", "String", true]
  #     ["options", Object, false]
  #   ]
  #   desc: """
  #     Creates an <i> element with a class "icon-#{name}", such as
  #     <i class="icon-magnifier
  #   """    

  def preventDefault: (event) -> event.preventDefault()
  # @::preventDefault.doc = 
  #   params: [
  #     [event, "DOMEvent", true]
  #   ]
  #   desc: """
  #     A useful event handler that prevents the default behavior.
  #     Use it in the events hash like so to prevent navigations on links
  #     with a 'stopped' class.
  #     ```coffee
  #       events:
  #          "click a.stopped": "preventDefault"
  #     ```
  #   """
    
  # DRAGGABLE
  require("transform_hooks") 
  jQuery.cssHooks.translateX || throw "Cannot be draggable without transform hooks"
  defs draggable: (config={}) ->
    @::dragWithProxy = config.dragWithProxy
    @::dragHandle = config.dragHandle
    @::dragX = config.dragX
    @::dragY = config.dragY

    @beforeContent (view) ->
      if view.dragHandle
        knead.monitor $ view.dragHandle, view.el
      else
        knead.monitor $ view.el

    eventConfig = {}

    if config.dragHandle
      eventConfig["knead:dragstart #{config.dragHandle}"] = "dragstart"
      eventConfig["knead:drag #{config.dragHandle}"] = "drag"
      eventConfig["knead:dragend"] = "dragend"
    else
      eventConfig["knead:dragstart"] = "dragstart"
      eventConfig["knead:drag"] = "drag"
      eventConfig["knead:dragend"] = "dragend"

    _.extend (@::events ||= {}), eventConfig

  defs droppable: (classPath, config) ->
    @::events ||= {}

    if @dropConfig is undefined
      @::events["drop @"] = "drop"
      @dropConfig ||= {}
  
    @dropConfig[classPath] = config

  def drop: (event, hit) ->
    model = event["as/model"].model
    for classPath, config of @constructor.dropConfig
      if model.constructor.path() is classPath
        config.drop?.call(this, model, hit)

  def proxyContent: -> @text "Drag Proxy"

  def dragstart: (event) ->
    event.preventDefault()
    event.stopImmediatePropagation()
    @proxy = if @dragWithProxy
      $ @withinNode @application.el, ->
        @div class:"#{@constructor._name()} DragProxy", @proxyContent
    else
     @el

    @halfProxy = 
      width: @el.outerWidth() / 2
      height: @el.outerHeight() / 2

    @proxy.width @el.width()
    @proxy.css position:"absolute", top:0, left:0

    @targets and for target in @targets()
      target.gather() 

  def drag: (event) ->
    event.preventDefault()
    event.stopImmediatePropagation()
    {startX, startY, deltaX, deltaY} = event
    nowX = startX + deltaX - @halfProxy.width
    nowY = startY + deltaY - @halfProxy.height
    css = {}
    css.translateX = nowX unless @dragX is false
    css.translateY = nowY unless @dragY is false

    @proxy.css css

    @targets and for target in @targets()
      target.drag("jquery/event":event)

    return

  def dragend: (event, hit) ->
    event.preventDefault()
    event.stopImmediatePropagation()
    @proxy.remove() if @dragWithProxy
    @targets and for target in @targets()
      target.dragend(
        "jquery/event": event
        "as/model": @model
      )

    Taxi.Governer.exit()