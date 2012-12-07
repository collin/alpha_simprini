sum = (array) -> _.reduce(array, ((memo, num) -> memo + num), 0)

class AS.Views.Region < AS.View
  def initialize: ->
    @_super.apply this, arguments
    @application?.bind "resize", => @layout()
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
  def layout: ->
  # @::layout.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """


class AS.Views.North < AS.Views.Region

class AS.Views.East < AS.Views.Region  
  def layout: ->
    @el.css
      top: @el.siblings(".North").outerHeight() or 0
      bottom: @el.siblings(".South").outerHeight() or 0
  # @::layout.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

class AS.Views.South < AS.Views.Region

class AS.Views.West < AS.Views.Region
  def layout: ->
    @el.css
      top: @el.siblings(".North").outerHeight() or 0
      bottom: @el.siblings(".South").outerHeight() or 0
  # @::layout.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

class AS.Views.Center < AS.Views.Region
  def layout: ->
    @el.css
      top: @el.siblings(".North").outerHeight() or 0
      bottom: @el.siblings(".South").outerHeight() or 0
      left: @el.siblings(".West").outerWidth() or 0
      right: @el.siblings(".East").outerWidth() or 0
  # @::layout.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
