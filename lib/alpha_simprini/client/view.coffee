AS = require("alpha_simprini")
_ = require("underscore")
fleck = require("fleck")

AS.View = AS.DOM.extend ({def}) ->
  def tagName: "div"

  def _ensureElement: -> @el ?= @$(@buildElement())

  def initialize: (config={}) ->
    @cid = _.uniqueId("c")

    for key, value of config
      if value instanceof AS.Model
        @[key] = AS.ViewModel.build(this, value)
      else
        @[key] = value

    @bindingGroup = AS.BindingGroup.new()
    @_ensureElement()
    @delegateEvents()

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

  def klassString: -> @constructor.path().replace /\./g, " "

  def baseAttributes: ->
    attrs =
      class: @klassString()

  def buildElement: ->
    @currentNode = @[@tagName](@baseAttributes())

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

