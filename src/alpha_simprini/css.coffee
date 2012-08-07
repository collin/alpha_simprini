require "alpha_simprini"
AS.part("CSS")

AS.CSS.DIMENSION_UNITS = "px % em /4 /6 /8 /12 /24 /36 /48 /72 /96".split(" ")
AS.CSS.DIMENSION_UNITS.unshift("") # Blank option
AS.CSS.SIZE_UNITS = "px em".split(" ")
AS.CSS.TEXT_UNITS = "px em % pt".split(" ")

AS.CSS.require """
  models/color models/color_stop models/color_stops models/percent
  models/length models/angle models/font_size models/font_family
  models/siding models/margin models/padding

  views/color_stop_picker views/dialogs/color views/angle_picker views/color_picker
"""
