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
    @el.data().view = this
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
    @childViews.push(view)
    @bindingGroup.addChild(view)
    @currentNode?.appendChild view.el[0] unless view.el.parent().is("*")
    view.el[0]
  # @::view.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
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
    if bindable instanceof AS.Collection or bindable instanceof AS.Model.HasMany.Instance
      AS.Binding.Many.new(this, bindable, bindable, options, fnOrElement)
    else if bindable instanceof AS.Model
      AS.Binding.Model.new(this, bindable, options or fnOrElement)
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
    if @events
      @standardEvents = AS.ViewEvents.new(this, @events)
      @standardEvents.applyBindings()

    stateEvents = _(@constructor::).chain().keys().filter (key) -> key.match(/_events$/)?
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
  # @::delegateEvents.doc =
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
    
