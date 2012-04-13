AS = require "alpha_simprini"
AS.Models.RadioSelectionModel = AS.Model.extend ({def}) ->
  @property 'selected'
  
  def initialize: ->
    @_super()
    @select undefined
  
  def select: (item) ->
    @selected.set(item)
