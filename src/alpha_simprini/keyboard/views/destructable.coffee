AS.Views.Destructable = AS.Module.extend ({delegate, include, def, defs}) ->
  def initialize: ->
    @events ?= {}
    @events["click .delete"] = "destroyModel"
    @_super.apply(this, arguments)
    

  def destroyModel: (event) -> 
    event.stopPropagation()
    @model.destroy()
