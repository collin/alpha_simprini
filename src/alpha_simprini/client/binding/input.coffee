class AS.Binding.Input < AS.Binding.Field
  def initialize: ->
    @_super.apply(this, arguments)
    if @options.bindingPath
      @context.binds @model, @options.bindingPath, @setContent, this
    else if _.isArray(@field)
      @context.binds @model, @field, @setContent, this
    else
      @context.binds @field, "change", @setContent, this
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def makeContent: ->
    @context.$ @context.input(@options)
  # @::makeContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def bindContent: ->
    @context.binds @content, "change", @setField, this
  # @::bindContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def setContent: () ->
    @content.val @fieldValue()
  # @::setContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def readField: ->
    @content.val()
  # @::readField.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def setField: () ->
    if _.isArray @field
      @model.writePath @field, @readField()
    else
      @field.set @readField()
  # @::setField.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
