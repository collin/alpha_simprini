class AS.Models.ZoneController < AS.Model
  @hasMany "zoneGroups"
  @hasOne "activeZoneGroup"
  @hasOne "defaultZoneGroup"

  def initialize: (config) ->
    @application = config.application
    delete config.application
    @_super.apply(this, arguments)
    
    for event in 'up down right left alphanum open'.split(" ")
      do (event) =>
        @application.bind
          event: event
          handler: (jqevent) -> @forwardAppEvent(event, jqevent)
          context: this

  @afterInitialize (model) ->
    unless model.defaultZoneGroup.get()
      model.defaultZoneGroup.set AS.Models.ZoneGroup.new()
  
    model.activateGroup()
  
  def activateGroup: (group=@defaultZoneGroup.get()) ->
    @deactivateGroup @activeZoneGroup.get()
    @activeZoneGroup.set(group)
    group.activate()
    
  def add: (group) ->
    @zoneGroups.add(group)

  def deactivateGroup: (group) ->
    return unless group
    @activeZoneGroup.set(null)
    group.deactivate()
  
  def forwardAppEvent: (event, jqevent) ->
    return true if $(jqevent.target).is(":input, [contenteditable]")
    return true unless group = @activeZoneGroup.get()
    group[event]?.call(group)
    