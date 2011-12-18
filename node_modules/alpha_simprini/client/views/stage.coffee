AS = require "alpha_simprini"
class AS.Stage extends AS.Views.Panel
  canvas_class: AS.Views.Canvas
  initialize: (config) ->
    super
    @canvas ?= new @canvas_class
    @el.append @canvas.el