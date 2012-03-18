AS = require("alpha_simprini")
_ = require "underscore"

AS.Binding.CheckBox = AS.Binding.Input.extend ({def}) ->
  def initialize: (context, model, field, options={}, fn=undefined) ->
    options.type = "checkbox"
    @_super.apply(this, arguments)

  def setContent: ->
    @content.attr "checked", @fieldValue()

  def bindContent: ->
    @context.binds @content, "change", _.bind(@setField, this)

  def setField: ->
    if @content.is ":checked"
      @field.set true
    else
      @field.set false
