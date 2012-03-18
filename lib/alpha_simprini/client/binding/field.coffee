AS = require("alpha_simprini")
_ = require "underscore"

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
      @container.empty()
      @bindingGroup.unbind()
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @container, =>
          @fn.call(@context)
    else
      @content.text @fieldValue()

  def makeContent: ->
    if @fn
      @context.$ []
    else
      @context.$ @context.span()