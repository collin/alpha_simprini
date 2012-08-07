AS.Models.Siding = AS.Model.extend ({delegate, include, def, defs}) ->
  @hasOne "top", dependant: 'destroy'
  @hasOne "right", dependant: 'destroy'
  @hasOne "bottom", dependant: 'destroy'
  @hasOne "left", dependant: 'destroy'