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
    @context.binds @content, "change", @setField, this

  def setContent: () ->
    @content.val @fieldValue()

  def readField: ->
    @content.val()

  def setField: () ->
    if _.isArray @field
      @model.writePath @field, @readField()
    else
      @field.set @readField()
