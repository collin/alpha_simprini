AS = require("alpha_simprini")
_ = require("underscore")
fleck = require("fleck")

AS.View = AS.DOM.extend ({def}) ->
  def tagName: "div"

  def _ensureElement: -> @el ?= @$(@build_element())

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

  def process_attr: (node, key, value) ->
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
    current_group = @bindingGroup
    @bindingGroup = bindingGroup
    content = fn.call(this, bindingGroup)
    @bindingGroup = current_group
    content

  def binds: -> @bindingGroup.binds.apply(@bindingGroup, arguments)

  def klassString: -> @constructor.path().replace /\./g, " "

  def baseAttributes: ->
    attrs =
      class: @klassString()

  def build_element: ->
    @currentNode = @[@tagName](@baseAttributes())

  def delegateEvents: () ->
    if @events
      @standard_events = AS.ViewEvents.new(this, @events)
      @standard_events.apply_bindings()

    state_events = _(@constructor::).chain().keys().filter (key) ->
      _(key).endsWith("_events")
    @state_events = {}
    for key in state_events.value()
      state = key.replace(/_events$/, '')
      do (key, state) =>
        @state_events[state] = AS.ViewEvents.new(this, @[key])

        @["exit_#{state}"] = ->
          @trigger("exitstate:#{state}")
          @state_events[state].revoke_bindings()

        @["enter_#{state}"] = ->
          @trigger("enterstate:#{state}")
          @state_events[state].apply_bindings()

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

