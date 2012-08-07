AS.Models.FontSize = AS.Model.extend ({delegate, include, def, defs}) ->
  @field "value"
  @field "unit"

  @virtualProperties 'value', 'unit',
    size: ->
      "#{@value.get()}#{@unit.get()}"