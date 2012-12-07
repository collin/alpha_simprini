module AS.Views.Zone
  def isActive: ->
    @addClass 'active-zone'

  def isntActive: ->
    @removeClass 'active-zone'
