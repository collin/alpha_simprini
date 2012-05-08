AS.Binding.Field = AS.Binding.extend ({def}) ->
  def initialize: ->
    @_super.apply this, arguments
    @setContent()
    @bindContent()
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def bindContent: ->
    # don't go thinking ou want to @withingBindingGroup @bindingGroup this.
    # you want this binding to take place in the context of the @context
    @context.binds @field, "change", @setContent, this
  # @::bindContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def setContent: ->
    if @fn
      @content.empty()
      @bindingGroup.unbind()

      fieldValue = @fieldValue()
      # FIXME: this turned into a string :(
      return if fieldValue is null
      return if fieldValue is undefined
      return if fieldValue is "null"
      return if fieldValue is "undefined"
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @content, =>
          if _.include(fieldValue.model?.constructor.ancestors, AS.Model)
            value = AS.ViewModel.build(@context, fieldValue.model)
            @fn.call(@context, value, AS.Binding.Model.new(@context, value, @container))

          else if _.include(fieldValue.model?.constructor.ancestors, AS.ViewModel)
            value = AS.ViewModel.build(@context, fieldValue.model.model)
            @fn.call(@context, value, AS.Binding.Model.new(@context, value, @container))

          else
            @fn.call(@context)
    else
      @content.text @fieldValue()
  # @::setContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def makeContent: ->
    if @fn
      AS.Binding.Container.new(@container[0])
    else
      @context.$ @context.span()
  # @::makeContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """