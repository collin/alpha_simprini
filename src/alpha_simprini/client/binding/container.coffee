class AS.Binding.Container
  delegate 'find', 'html', 'contents', 'append', to: 'el'

  def initialize: (object) ->
    @domElement = object.domElement || object[0]
    @el = jQuery(@domElement)
    @containerChildren = []
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def append: (child) -> @appendChild(child)

  def appendChild: (child) ->
    if child instanceof jQuery
      child.each (index, node) => @containerChildren.push node
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
