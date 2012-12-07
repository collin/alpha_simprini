module AS.Views.KeyboardNavigation
  def initialize: ->
    @events ?= {}
    @events["open @"] = "openCurrent"

    @_super.apply(this, arguments)
    @selectDefault()

  def selectDefault: ->
    @navigableSelection().select @selectableViews()[0]

  def up: ->
    views = @selectableViews()
    index = Math.max 0, (_.indexOf views, @currentSelection()) - 1
    @navigableSelection().select views[index]

  def down: ->
    views = @selectableViews()
    index = Math.min (views.length - 1), (_.indexOf views, @currentSelection()) + 1
    @navigableSelection().select views[index]

  def currentSelection: ->
    @navigableSelection().selected.get()

  def openCurrent: ->
    @navigableSelection().selected.get()?._input.trigger('dblclick')
