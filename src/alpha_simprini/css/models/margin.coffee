AS.Models.Margin = AS.Models.Siding.extend ({delegate, include, def, defs}) ->
  for side in "top right bottom left".split(" ")
    @properties[side].options.model = -> AS.Models.Length
