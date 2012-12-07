class AS.Models.FontSize < AS.Model
  @field "value"
  @field "unit"

  @virtualProperties 'value', 'unit',
    size: ->
      "#{@value.get()}#{@unit.get()}"