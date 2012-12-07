module AS.Views.Destructable
  def initialize: ->
    @events ?= {}
    @events["click .delete"] = "destroyModel"
    @_super.apply(this, arguments)
    

  def destroyModel: (event) -> 
    event.stopPropagation()
    @model.destroy()
