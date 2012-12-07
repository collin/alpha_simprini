class AS.Models.ZoneGroup < AS.Model
  @hasMany "zones", model: -> AS.Models.Zone
  @hasOne "activeZone"

  def up: ->
    @activeZone.get().item.get().up?()

  def down: ->
    @activeZone.get().item.get().down?()

  def left: ->
    @activateZone @prev()

  def right: ->
    @activateZone @next()

  def alphanum: ->
    @activeZone.get()?.item.get().trigger("alphanum")
  
  def open: ->
    @activeZone.get()?.item.get().trigger("open")

  def add: (zones...) ->
    @zones.add(item:zone, group:this) for zone in zones

  def deactivate: ->
    @activeZone.get()?.deactivate()
  
  def activate: -> @activateZone()

  def activateZone: (zone=@zones.first().value()) ->
    return unless zone
    @activeZone.get()?.deactivate()
    @activeZone.set(zone)
    zone.activate()

  def next: ->
    index = @zones.indexOf(@activeZone.get()).value()
    if index is -1
      @zones.first().value()
    else
      @zones.at(index + 1) or @zones.first().value()

  def prev: ->
    index = @zones.indexOf(@activeZone.get()).value()
    if index is -1
      @zones.last().value()
    else
      @zones.at(index - 1) or @zones.last().value()
    