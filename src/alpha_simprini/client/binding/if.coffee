class AS.Binding.Conditional < AS.Binding.Field
  defs willGroupBindings: true

  def setContent: ->
    @content.empty()
    @bindingGroup.unbind()

    value = fieldValue = @fieldValue()

    value = false if fieldValue in [null, undefined, "null", "undefined", "false", false]

    value = AS.ViewModel.build(this, value) if value instanceof AS.Model

    if @condition(value)
      contentFn = @options.then
    else
      contentFn = @options.else

    # contentFn = if value then @options.then else @options.else
    if contentFn
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @content, =>
          contentFn.call(@context, value)

  # @::setContent.doc =
  #   desc: """
  #     Sets the content based on the fieldValue and the given branches.
  #   """


class AS.Binding.If < AS.Binding.Conditional
  def condition: (value) ->
    value isnt false

class AS.Binding.Unless < AS.Binding.Conditional
  def condition: (value) ->
    not(value isnt @compareTo)
  

    
