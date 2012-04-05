AS = require("alpha_simprini")
_ = require "underscore"
jQuery = require "jquery"

AS.Binding.One = AS.Binding.Field.extend ({delegate, include, def, defs}) ->
  def makeContent: ->
    @content = @context.$ []
    
  def setContent: ->
    @content.remove()

    if (value = @fieldValue()) and @fn
      value = AS.ViewModel.build(@context, value) if _.include(value.constructor.ancestors, AS.Model)
      @bindingGroup.unbind()
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @container, =>
          made = @fn.call(@context, value, AS.Binding.Model.new(@context, @model, @container))
          @content.push if made instanceof jQuery then made[0] else made

    else
      @bindingGroup.unbind() 
