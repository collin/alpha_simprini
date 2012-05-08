AS.Views.Stage = AS.Views.Panel.extend ({delegate, include, def, defs}) ->
  def canvas_class: AS.Views.Canvas
  def initialize: (config) ->
    @_super.apply(this, arguments)
    @canvas ?= AS.Views.Canvas.new()
    @el.append @canvas.el
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """