# AS = require("alpha_simprini")
# _ = require "underscore"

# # Example:
# #
# # class StopLight
# #   AS.StateMachine.extends(this)
# #   @event "stop_soon"
# #   @event "stop_now"
# #   @event ""
# AS.StateMachine = new AS.Mixin
#   instance_methods:
#     transition_state: (options) ->
#       if @state is options.from
#         @["exit_#{@state}"]?(options) if @state # default state comes from nowhere
#         @state = options.to
#         @["enter_#{options.to}"]?(options)

#     default_state: (state) ->
#       @transition_state from:undefined, to:state

