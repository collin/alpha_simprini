AS = require("alpha_simprini")
_ = require("underscore")
fleck = require("fleck")

class AS.View extends AS.DOM
  AS.Event.extends(this)
  AS.StateMachine.extends(this)
    
  tag_name: "div"
    
  _ensure_element: -> @el ?= @$(@build_element())
    
  constructor: (config={}) ->
    @cid = _.uniqueId("c")

    for key, value of config
      if value instanceof AS.Model
        @[key] = AS.ViewModel.build(this, value)
      else
        @[key] = value

    @binding_group = new AS.BindingGroup
    @_ensure_element()
    @delegateEvents()
    @initialize()
    
  initialize: ->
    
  append: (view) -> @el.append view.el
    
  process_attr: (node, key, value) ->
    if value instanceof Function
      # switch value
      # when AS.Binding.Field
      #   false
      # else
      #   false
    else
      node.setAttribute(key, value)
    
  group_bindings: (fn) ->
    @within_binding_group @binding_group.add_child(), fn
      
  within_binding_group: (binding_group, fn) ->
    current_group = @binding_group
    @binding_group = binding_group
    content = fn.call(this, binding_group)
    @binding_group = current_group
    content
    
  binds: -> @binding_group.binds.apply(@binding_group, arguments)
    
  klass_string: (parts=[]) ->
    if @constructor is AS.View
      # parts.push "ASView"
      parts.reverse().join " "
    else
      parts.push @constructor.name
      @constructor.__super__.klass_string.call @constructor.__super__, parts

  base_attributes: ->
    attrs =
      class: @klass_string()
      
  build_element: ->
    @current_node = @[@tag_name](@base_attributes())
  
  delegateEvents: () ->
    if @events
      @standard_events = new AS.ViewEvents(this, @events)
      @standard_events.apply_bindings()
      
    state_events = _(@constructor::).chain().keys().filter (key) -> 
      _(key).endsWith("_events")
    @state_events = {}
    for key in state_events.value()
      state = key.replace(/_events$/, '')
      do (key, state) =>
        @state_events[state] = new AS.ViewEvents(this, @[key])
          
        @["exit_#{state}"] = ->
          @trigger("exitstate:#{state}")
          @state_events[state].revoke_bindings()
          
        @["enter_#{state}"] = -> 
          @trigger("enterstate:#{state}")
          @state_events[state].apply_bindings()

  pluralize: (thing, count) ->
    if count in [-1, 1]
      "#{count} #{fleck.singularize(thing)}"
    else
      "#{count} #{fleck.pluralize(thing)}"
  
  reset_cycle: (args...) ->
    delete @_cycles[args.join()] if @_cycles

  cycle: (args...) ->
    @_cycles ?= {}
    @_cycles[args.join()] ?= 0
    count = @_cycles[args.join()] += 1
    args[count % args.length]

  toggle: ->
    @button class:"toggle expand"
    @button class:"toggle collapse"
        
  field: (_label, options = {}, fn = ->) ->
    if _.isFunction options
      fn = options
      options = {}
        
    @div ->
      @label _label
      @input(options)
      fn?.call(this)
        
  choice: (_label, options = {}, fn = ->) ->
    if _.isFunction options
      fn = options
      options = {}
    options.type = "checkbox"
      
    @field _label, options, fn

