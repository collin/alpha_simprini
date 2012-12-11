class AS.Binding.CheckBox < AS.Binding.Input
  def initialize: (context, model, field, options={}, fn=undefined) ->
    options.type = "checkbox"
    @_super.apply(this, arguments)
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def setContent: ->
    @content.attr "checked", @fieldValue()
  # @::setContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def bindContent: ->
    @context.binds @content, "change", _.bind(@setField, this)
  # @::bindContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def setField: ->
    if @content.is ":checked"
      @field.set true
    else
      @field.set false
  # @::setField.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
