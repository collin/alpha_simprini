AS = require "alpha_simprini"
AS.require "views/panel views/canvas"
class AS.Stage extends AS.Panel
  canvas_class: AS.Views.Canvas
  initialize: (config) ->
    super
    @canvas ?= new @canvas_class
    @el.append @canvas.el