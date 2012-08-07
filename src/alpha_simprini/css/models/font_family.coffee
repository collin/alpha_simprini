AS.Models.FontFamily = AS.Model.extend ({delegate, include, def, defs}) ->
  @field "name"
  @field "fallback"

  def toCSS: -> "#{@name()}, #{@fallback()}"

create = (id, name, fallback) ->
  AS.Models.FontFamily.new
    name: name
    fallback: fallback
    id: "TypeFace-#{id}"

serif = (id, name) -> create(id, name, "serif")
sans = (id, name) -> create(id, name, "sans-serif")
mono = (id, name) -> create(id, name, "monospace")

# THE ID OF THESE FONTS
# IS NOT MERELY AN IMPLEMENTATION DETAIL
# BUT A POINT IN THE DATABASE!

# DO NOT CHANGE THEM WITHOUT APPROPRIATELY MIGRATING
AS.CSS.FontFamilies = [
  serif  0, "Georgia"
  serif  1, "Times New Roman"
  sans   2, "Andale Mono"
  sans   3, "Arial"
  sans   4, "Arial Black"
  serif  5, "Century Gothic"
  sans   6, "Impact"
  sans   7, "Trebuchet MS"
  sans   8, "Verdana"
  mono   9, "Courier New"
  # THESE ARE MOST LIKELY NOT GOING TO BE CORE FONTS IN PRODUCTION!
  mono  10, "monofur"
  sans  11, "Palatino"
  sans  12, "Optima"
]

options = AS.CSS.FontFamilies.options = {}
_.each AS.CSS.FontFamilies, (family) ->
  options[family.name.get()] = family.id
