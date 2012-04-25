AS.Binding.One = AS.Binding.Field.extend ({delegate, include, def, defs}) ->
  def makeContent: ->
    AS.Binding.Container.new(@container[0])

  def setContent: ->
    @content.empty()
    @bindingGroup.unbind()

    if (value = @fieldValue()) and @fn
      value = AS.ViewModel.build(@context, value) if _.include(value.constructor.ancestors, AS.Model)
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @content, =>
          @fn.call(@context, value, AS.Binding.Model.new(@context, @model, @container))
