class AS.Models.Zone < AS.Model
  @property "item", 
    get: ->
      return unless @value
      hit = window
      for identifier in @value
        hit = hit?[identifier]

      hit

  @belongsTo "group"

  def activate: ->
    @item.get().isActive()
    
  def deactivate: ->
    @item.get().isntActive()
