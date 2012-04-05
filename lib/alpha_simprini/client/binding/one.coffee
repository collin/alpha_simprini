AS = require("alpha_simprini")
_ = require "underscore"

AS.Binding.One = AS.Binding.Field.extend ({delegate, include, def, defs}) ->
  @willGroupBindings = true

  def setContent: ->
    if (value = @fieldValue()) and @fn
      value = AS.ViewModel.build(@context, value) if _.include(value.constructor.ancestors, AS.Model)
      @container.empty()
      @bindingGroup.unbind()
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @container, =>
          @fn.call(@context, value, AS.Binding.Model.new(@context, @model, @container))
    else
      @bindingGroup.unbind()
      @container.empty()    
