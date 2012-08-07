AS.Views.Zone = AS.Module.extend ({delegate, include, def, defs}) ->
  def isActive: ->
    @addClass 'active-zone'

  def isntActive: ->
    @removeClass 'active-zone'
