class AS.Binding.One < AS.Binding.Field
  def makeContent: ->
    AS.Binding.Container.new @container
  # @::makeContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def setContent: ->
    @content.empty()
    @bindingGroup.unbind()

    if (value = @fieldValue()) and @fn
      value = AS.ViewModel.build(@context, value) if _.include(value.constructor.ancestors, AS.Model)
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @content, =>
          @fn.call(@context, value, AS.Binding.Model.new(@context, @model, @container))
  # @::setContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """