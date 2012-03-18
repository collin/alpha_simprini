AS = require("alpha_simprini")
_ = require "underscore"

AS.Binding.Input = AS.Binding.Field.extend ({def}) ->
  def initialize: ->
    @_super.apply(this, arguments)
    @context.binds @field, "change", @setContent, this

  def makeContent: ->
    @context.$ @context.input(@options)

  def bindContent: ->
    @context.binds @content, "change", _.bind(@setField, this)

  def setContent: () ->
    @content.val @fieldValue()

  def setField: () ->
    @field.set @content.val()
