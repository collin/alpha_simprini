AS = require("alpha_simprini")
# Example:
#
# class StopLight
#   AS.StateMachine.extends(this)
#   @event "stop_soon"
#   @event "stop_now"
#   @event ""
AS.StateMachine = new AS.Mixin
  # mixed_in: (klass) ->
  #   klass.state_namespace = _.uniqueId(".sm")
  
  # class_methods:
  #   event: (name, options) ->
  #     @events ?= []
  #     options.name = name
  #     @events.push options
      
    # to_dot: () ->
    #   dot = ["digraph G {"]
    #  
    #   for event in @events
    #     for state in event.from.split " "
    #       for trigger in event.via.split " "
    #         dot.push "  #{state} -> #{event.to} [label=\"#{trigger}\"];"
    # 
    #   dot.push "}"
    #   dot.join("\n")
    
  instance_methods:
    transition_state: (options) ->
      if @state is options.from
        @["exit_#{@state}"]?(options) if @state # default state comes from nowhere
        console.log "transition from #{@state} to #{options.to}"
        @state = options.to
        @["enter_#{options.to}"]?(options)
      
    default_state: (state) ->
      @transition_state from:undefined, to:state
      
    # bind_state_machine_to: (object) ->
    #   for event in @constructor.events
    #     for trigger in event.via.split(" ")
    #       namespaced_trigger = trigger + @constructor.state_namespace
    #       object.bind namespaced_trigger, (event) => @process(event)
    #   
    # process: (event) ->
    #   state_event = _.detect @constructor.events, (_event) =>
    #     _event.via.match(event.type) and _event.from.match(@state)
    #     
    #   @transition_state(state_event) if state_event
