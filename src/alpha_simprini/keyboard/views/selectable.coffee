module AS.Views.Selectable
  def initialize: ->
    @events ?= {}
    @events["click"] = "activateSelf"
    @_super.apply(this, arguments)

  def activateSelf: (event) ->
    if event
      return unless @el.is(event.currentTarget)
    @navigableSelection().select @model
    
