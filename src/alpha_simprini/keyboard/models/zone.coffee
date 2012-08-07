AS.Models.Zone = AS.Model.extend ({delegate, include, def, defs}) ->
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
