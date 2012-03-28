AS = require "alpha_simprini"
AS.Views.Stage = AS.Views.Panel.extend ({delegate, include, def, defs}) ->
  def canvas_class: AS.Views.Canvas
  def initialize: (config) ->
    super
    @canvas ?= AS.Views.Canvas.new()
    @el.append @canvas.el