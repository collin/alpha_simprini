class AS.Binding.If < AS.Binding.Field
  def setContent: ->
    @content.empty()
    @bindingGroup.unbind()

    value = fieldValue = @fieldValue()

    value = false if fieldValue in [null, undefined, "null", "undefined", "false", false]

    if value isnt false
      contentFn = @options.then
    else
      contentFn = @options.else

    contentFn = if value then @options.then else @options.else
    return unless contentFn

    @context.withinBindingGroup @bindingGroup, =>
      @context.withinNode @content, =>
        contentFn.call(@context)

    @bindContent()
  # @::setContent.doc =
  #   desc: """
  #     Sets the content based on the fieldValue and the given branches.
  #   """

