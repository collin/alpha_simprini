AS = require("alpha_simprini")
_ = require "underscore"

AS.Binding.Select = AS.Binding.Input.extend ({def}) ->
  def initialize: ->
    @_super.apply(this, arguments)
    @require_option "options"

  def makeContent: ->
    options = @options.options
    @select = @context.$ @context.select ->
      if _.isArray options
        for option in options
          @option option.toString()
      else
        for key, value of options
          @option value: value, -> key

  def setContent: () ->
    fieldValue = @fieldValue()
    fieldValue = fieldValue.id if fieldValue?.id
    @content.val fieldValue

  def setField: ->
    value = @select.val()
    if _.isArray value
      @field.set value[0]
    else
      @field.set value