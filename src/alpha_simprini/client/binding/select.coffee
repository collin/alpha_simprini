AS.Binding.Select = AS.Binding.Input.extend ({def}) ->
  def initialize: ->
    @_super.apply(this, arguments)
    @require_option "options"

  def makeContent: ->
    @select?.remove()
    options = @options.options
    @select = @context.$ @context.select ->
      if _.isArray options
        for option in options
          @option option.toString()
      else
        for key, value of options
          @option value: value, -> key

  def setContent: () ->
    fieldValue = @fieldValue()
    fieldValue = fieldValue.id if fieldValue?.id
    @content.val fieldValue

  def setField: ->
    value = @select.val()
    value = if _.isArray value then value[0] else value

    if _.isArray @field
      @model.writePath @field, value
    else
      @field.set value
