AS = require("alpha_simprini")
_ = require "underscore"
jQuery = require "jquery"

AS.Binding.Field = AS.Binding.extend ({def}) ->

  def initialize: ->
    @_super.apply this, arguments
    @content = @makeContent()
    @bindContent()
    @setContent()

  def bindContent: ->
    @context.binds @field, "change", @setContent, this

  def setContent: ->
    if @fn
      @content.remove()
      @container.empty()

      fieldValue = @fieldValue()
      # FIXME: this turned into a string :(
      return if fieldValue is null
      return if fieldValue is undefined
      return if fieldValue is "null"
      return if fieldValue is "undefined"
      @bindingGroup.unbind()
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @container, =>
          made = if _.include(fieldValue.model?.constructor.ancestors, AS.Model)
            value = AS.ViewModel.build(@context, fieldValue.model)
            made = @fn.call(@context, value, AS.Binding.Model.new(@context, value, @container))
          else
            @fn.call(@context)
          @content.push if made instanceof jQuery then made[0] else made
    else
      @content.text @fieldValue()

  def makeContent: ->
    @content = if @fn
      @context.$ []
    else
      @context.$ @context.span()