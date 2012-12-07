class AS.Models.Siding < AS.Model
  @hasOne "top", dependant: 'destroy'
  @hasOne "right", dependant: 'destroy'
  @hasOne "bottom", dependant: 'destroy'
  @hasOne "left", dependant: 'destroy'