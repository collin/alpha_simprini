AS = require("alpha_simprini")
_ = require "underscore"

AS.Binding.Input = AS.Binding.Field.extend ({def}) ->
  def initialize: ->
    @_super.apply(this, arguments)
    if _.isArray @field
      @context.binds @model, @field, @setContent, this
    else
      @context.binds @field, "change", @setContent, this

  def makeContent: ->
    @context.$ @context.input(@options)

  def bindContent: ->
    if _.isArray @field
      @context.binds @model, @field, @setField, this
    else
      @context.binds @content, "change", @setField, this

  def setContent: () ->
    @content.val @fieldValue()

  def setField: () ->
    if _.isArray @field
      @model.writePath @field, @content.val()
    else
      @field.set @content.val()
