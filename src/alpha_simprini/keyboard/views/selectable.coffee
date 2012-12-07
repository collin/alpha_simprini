module AS.Views.Selectable
  def initialize: ->
    @events ?= {}
    @events["click"] = "activateSelf"
    @_super.apply(this, arguments)

  def activateSelf: (event) ->
    if event
      return unless $(event.target).parent()[0] is @el[0]
    @navigableSelection().select(this)
    
