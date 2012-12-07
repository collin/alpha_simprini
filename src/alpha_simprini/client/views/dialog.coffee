require "knead"

module AS.Views.Dialogs

class As.Views.Dialog < As.Views.Panel
  @afterContent (view) -> knead.monitor view.head

  def initialize: ->
    @constructor::events ?= {}
    _.extend @constructor::events,
      "click .accept": "triggerCommit"
      "click .cancel": "triggerCancel"
      "esc @application": "triggerCancel"
      "accept @application": "triggerCommit"

      "knead:dragstart header": "dragstart"
      "knead:drag header": "drag"
      "knead:dragend header": "dragend"

    @_super.apply(this, arguments)
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def content: ->
    @head = @$ @header @headerContent
    @content = @$ @section @mainContent
    @foot = @$ @footer @footerContent
  # @::content.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def headerContent: ->
  # @::headerContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
  def mainContent: ->
  # @::mainContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
  def footerContent: ->
    @accept = @$ @button class:"accept", -> "Accept"
    @cancel = @$ @a href:"#", class:"cancel", -> "cancel"
  # @::footerContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def open: ->
    @el.css width: "", height: ""
    @trigger "open"
  # @::open.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def close: ->
    @el.css width: 0, height: 0, overflow: "hidden"
    @trigger "close"
  # @::close.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def triggerCommit: ->
    @trigger "commit"
    @close()
  # @::triggerCommit.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def triggerCancel: ->
    @trigger "cancel"
    @close()
  # @::triggerCancel.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """


  def dragstart: (event) ->
    @start = @el.position()
  # @::dragstart.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def drag: (event) ->
    @el.css
      top: event.deltaY + @start.top
      left: event.deltaX + @start.left
  # @::drag.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def dragend: (event) ->
    delete @start
  # @::dragend.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
