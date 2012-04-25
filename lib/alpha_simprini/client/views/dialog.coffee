AS = require "alpha_simprini"
_ = require "underscore"
knead = require "knead"

AS.Views.Dialog = AS.Views.Panel.extend ({delegate, include, def, defs}) ->
  def initialize: ->
    @constructor::events ?= {}
    _.extend @constructor::events,
      "click .accept": "trigger_commit"
      "click .cancel": "trigger_cancel"
      "esc @application": "trigger_cancel"
      "accept @application": "trigger_commit"

      "knead:dragstart header": "dragstart"
      "knead:drag header": "drag"
      "knead:dragend header": "dragend"

    @_super.apply(this, arguments)

  def content: ->
    @head = @$ @header @header_content
    @content = @$ @section @main_content
    @foot = @$ @footer @footer_content
    knead.monitor @head

  def header_content: ->
  def main_content: ->
  def footer_content: ->
    @accept = @$ @button class:"accept", -> "Accept"
    @cancel = @$ @a href:"#", class:"cancel", -> "cancel"

  def open: ->
    @el.css width: "", height: ""
    @trigger "open"

  def close: ->
    @el.css width: 0, height: 0, overflow: "hidden"
    @trigger "close"

  def trigger_commit: ->
    @trigger "commit"
    @close()

  def trigger_cancel: ->
    @trigger "cancel"
    @close()

  def dragstart: (event) ->
    @start = @el.position()
  def drag: (event) ->
    @el.css
      top: event.deltaY + @start.top
      left: event.deltaX + @start.left
  def dragend: (event) ->
    delete @start
