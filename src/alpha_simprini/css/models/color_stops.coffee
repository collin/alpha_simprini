{sortBy, map} = _

class AS.Models.ColorStops < AS.Model
  @afterInitialize (model) => 
    model.angle.set @properties.angle.options.model().new()

  @belongsTo 'angle',
    model: -> AS.Models.Angle

  @hasMany 'stops', 
    model: -> AS.Models.ColorStop

  @virtualProperties 'stops', 'angle',
    linearGradient: ->
      ordered = sortBy @stops.toArray().value(), (stop) -> stop.stop.get()
      stops = map ordered, (stop) -> "#{stop.rgba.get()} #{stop.stop.get()}%"
      degrees = ( @angle.get().degrees.get() - 90 ) + "deg"
      "#{AS.prefix}linear-gradient(#{degrees}, #{stops.join(',')})"