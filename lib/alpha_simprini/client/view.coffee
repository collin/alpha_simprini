AS = require("alpha_simprini")
Taxi = require("taxi")
_ = require("underscore")
fleck = require("fleck")

AS.View = AS.DOM.extend ({delegate, include, def, defs}) ->
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
    @el.data().view = this

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

  def content: ->
    # Make your content here.

  def append: (view) -> @el.append view.el

  def processAttr: (node, key, value) ->
  #   if value instanceof Function
  #     # switch value
  #     # when AS.Binding.Field
  #     #   false
  #     # else
  #     #   false
  #   else
    node.setAttribute(key, value)

  def groupBindings: (fn) ->
    @withinBindingGroup @bindingGroup.addChild(), fn

  def withinBindingGroup: (bindingGroup, fn) ->
    currentGroup = @bindingGroup
    @bindingGroup = bindingGroup
    content = fn.call(this, bindingGroup)
    @bindingGroup = currentGroup
    content

  def binds: -> @bindingGroup.binds.apply(@bindingGroup, arguments)

  def klassString: -> 
    classes = []
    for ancestor in @constructor.ancestors
      continue unless ancestor.path().match(/Views?/)
      classes.push ancestor._name()

    classes.join(" ")

  def baseAttributes: ->
    attrs =
      class: @klassString()
      id: @objectId()

  def buildElement: ->
    @currentNode = @[@tagName]()

  def view: (constructor, options={}) ->
    options.application = @application
    options.parentView = this
    view = constructor.new(options)
    @childViews.push(view)
    @bindingGroup.addChild(view)
    @currentNode?.appendChild view.el[0]
    view.el[0]

  def descendantViews: (views=[], constructor) ->
    for view in @childViews
      if constructor
        views.push view if view instanceof constructor
      else
        views.push view
      view.descendantViews(views, constructor)

    views

  def removeChild: (child) ->
    @childViews = _.without(@childViews, child)

  # DO NOT OVERRIDE #unbind
  def unbind: ->
    # AS.warn("Do not OVERRIDE View.unbind")
    @_super.apply(this, arguments)
  #   @parentView?.removeChild(this)
  #   @el.remove()

  def binding: (bindable, options, fnOrElement) ->
    if bindable instanceof AS.Collection or bindable instanceof AS.Model.HasMany.Instance
      AS.Binding.Many.new(this, bindable, bindable, options, fnOrElement)
    else if bindable instanceof AS.Model
      AS.Binding.Model.new(this, bindable, options or fnOrElement)

  def modelBinding: ->
    @_modelBinding ?= AS.Binding.Model.new(this, @model, @el)

  def bindAttrs: ->
    return unless @attrBindings
    @modelBinding().attr @attrBindings    

  def delegateEvents: () ->
    if @events
      @standardEvents = AS.ViewEvents.new(this, @events)
      @standardEvents.applyBindings()

    stateEvents = _(@constructor::).chain().keys().filter (key) ->
      _(key).endsWith("_events")
    @stateEvents = {}
    for key in stateEvents.value()
      state = key.replace(/_events$/, '')
      do (key, state) =>
        @stateEvents[state] = AS.ViewEvents.new(this, @[key])

        @["exit_#{state}"] = ->
          @trigger("exitstate:#{state}")
          @stateEvents[state].revokeBindings()

        @["enter_#{state}"] = ->
          @trigger("enterstate:#{state}")
          @stateEvents[state].applyBindings()

  # TODO: put these into modules or something.
  def pluralize: (thing, count) ->
    if count in [-1, 1]
      fleck.singularize(thing)
    else
      fleck.pluralize(thing)

  def reset_cycle: (args...) ->
    delete @_cycles[args.join()] if @_cycles

  def cycle: (args...) ->
    @_cycles ?= {}
    @_cycles[args.join()] ?= 0
    count = @_cycles[args.join()] += 1
    args[count % args.length]

  def toggle: ->
    @button class:"toggle expand"
    @button class:"toggle collapse"

  def field: (_label, options = {}, fn = ->) ->
    if _.isFunction options
      fn = options
      options = {}

    @div ->
      @label _label
      @input(options)
      fn?.call(this)

  def choice: (_label, options = {}, fn = ->) ->
    if _.isFunction options
      fn = options
      options = {}
    options.type = "checkbox"

    @field _label, options, fn

