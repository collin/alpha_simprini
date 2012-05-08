sum = (array) -> _.reduce(array, ((memo, num) -> memo + num), 0)

AS.Views.Region = AS.View.extend ({def}) ->
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

AS.Views.North = AS.Views.Region.extend ({def}) ->
AS.Views.East = AS.Views.Region.extend ({def}) ->
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

AS.Views.South = AS.Views.Region.extend ({def}) ->
AS.Views.West = AS.Views.Region.extend ({def}) ->
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

AS.Views.Center = AS.Views.Region.extend ({def}) ->
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
