AS = require "alpha_simprini"
class AS.Views.Stage extends AS.Views.Panel
  canvas_class: AS.Views.Canvas
  initialize: (config) ->
    super
    @canvas ?= new AS.Views.Canvas
    console.log @canvas.el[0].outerHTML
    @el.append @canvas.el