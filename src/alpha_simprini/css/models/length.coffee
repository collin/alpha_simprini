AS.Models.Length = AS.Model.extend ({delegate, include, def, defs}) ->
  @field 'value', type: AS.Model.Number
  @field 'unit'

  GRID = 960
  COLUMNS = {}
  for columns in "4 6 8 12 24 36 48 72 96".split(" ")
    COLUMNS["/#{columns}"] = GRID / parseInt(columns, 10)

  @virtualProperties 'value', 'unit',
    length: ->
      unit = @unit.get()
      value = @value.get()
      return "" unless value
      if unit in ["%", "em", "px", undefined, null]
        "#{value}#{unit or 'px'}"
      else if unit.match /^\/[\d]+$/
        "#{COLUMNS[unit] * value}px"
