AS = require "alpha_simprini"
_ = require "underscore"

sum = (array) -> _.reduce(array, ((memo, num) -> memo + num), 0)

class AS.Views.Region extends AS.View
  initialize: ->
    @application?.bind "resize", => @layout()
  layout: ->
class AS.Views.North extends AS.Views.Region
class AS.Views.East extends AS.Views.Region
  layout: ->
    @el.css
      top: @el.siblings(".North").outerHeight() or 0
      bottom: @el.siblings(".South").outerHeight() or 0

class AS.Views.South extends AS.Views.Region
class AS.Views.West extends AS.Views.Region
  layout: ->
    @el.css
      top: @el.siblings(".North").outerHeight() or 0
      bottom: @el.siblings(".South").outerHeight() or 0

class AS.Views.Center extends AS.Views.Region
  layout: ->
    @el.css
      top: @el.siblings(".North").outerHeight() or 0
      bottom: @el.siblings(".South").outerHeight() or 0
      left: @el.siblings(".West").outerWidth() or 0
      right: @el.siblings(".East").outerWidth() or 0
