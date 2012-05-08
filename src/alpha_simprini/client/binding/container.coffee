AS.Binding.Container = AS.Object.extend ({delegate, include, def, defs}) ->
  delegate 'find', 'html', to: 'el'

  def initialize: (@domElement) ->
    @el = jQuery(@domElement)
    @containerChildren = []
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def appendChild: (child) ->
    if child instanceof jQuery
      @containerChildren = @containerChildren.concat child
      child.appendTo(@domElement)
    else
      @containerChildren.push child
      @domElement.appendChild(child)
  # @::appendChild.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def empty: ->
    jQuery(@containerChildren).remove()
    @containerChildren = []
  # @::empty.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
