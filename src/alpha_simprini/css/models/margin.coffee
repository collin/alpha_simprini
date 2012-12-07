class AS.Models.Margin < AS.Models.Siding
  for side in "top right bottom left".split(" ")
    @properties[side].options.model = -> AS.Models.Length
