_ = require("underscore")
AS = require "alpha_simprini"
AS.Binding.File = AS.Binding.Input.extend ({delegate, include, def, defs}) ->
  def makeContent: ->
    options = _.clone(@options)
    options.type = "file"
    @context.$ @context.input(options)

  def fieldValue: -> # FALSE. Cannot set value of a file input.
  def setContent: -> # FALSE. Cannot set value of a file input.
  def readField: ->
    AS.Models.File.new file: @content[0].files[0]

    