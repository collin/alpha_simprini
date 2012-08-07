AS.Binding.Select = AS.Binding.Input.extend ({def}) ->
  def initialize: ->
    @_super.apply(this, arguments)
    @requireOption "options"
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def makeContent: ->
    @select?.remove()
    options = @options.options
    @select = @context.$ @context.select ->
      if _.isArray options
        for option in options
          @option option.toString()
      else
        for key, value of options
          @option value: value, -> key
  # @::makeContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def setContent: () ->
    fieldValue = @fieldValue()
    fieldValue = fieldValue.id if fieldValue?.id
    @content.val fieldValue
  # @::setContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
