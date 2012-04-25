# Example:
#
# StopLight = AS.Model.extend ({delegate, include, def, defs}) ->
#   include AS.StateMachine.extends(this)
#   @event "stop_soon"
#   @event "stop_now"
#   @event ""
AS.StateMachine = AS.Module.extend ({def}) ->
  def transitionState: (options) ->
    if @state is options.from
      @["exit_#{@state}"]?(options) if @state # default state comes from nowhere
      @state = options.to
      @["enter_#{options.to}"]?(options)
  # @::transitionState.doc =
  #   params: [
  #     ["options", Object, true]
  #   ]
  #   desc: """
  #
  #   """

  def defaultState: (state) ->
    @transitionState from:undefined, to:state
  # @::defaultState.doc =
  #   params: [
  #     ["state", String, true]
  #   ]
  #   desc: """
  #
  #   """

