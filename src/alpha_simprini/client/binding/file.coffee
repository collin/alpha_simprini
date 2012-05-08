AS.Binding.File = AS.Binding.Input.extend ({delegate, include, def, defs}) ->
  def makeContent: ->
    options = _.clone(@options)
    options.type = "file"
    @context.$ @context.input(options)
  # @::makeContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def fieldValue: -> # FALSE. Cannot set value of a file input.
  # @::fieldValue.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
  def setContent: -> # FALSE. Cannot set value of a file input.
  # @::setContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
  def readField: ->
    AS.Models.File.new file: @content[0].files[0]
  # @::readField.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

    