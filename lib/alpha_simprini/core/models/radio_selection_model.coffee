AS = require "alpha_simprini"
AS.Models.RadioSelectionModel = AS.Model.extend ({def}) ->
  @property 'selected'
  
  def initialize: (options={}) ->
    @property = options.property
    @_super()
    @select undefined
  
  def select: (item) ->
    if @property
      @selected.get()?[@property].set(null)
      item?[@property].set(true)

    @selected.set(item)
