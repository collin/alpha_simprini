AS = require "alpha_simprini"
AS.Models.RadioSelectionModel = AS.Model.extend ({def}) ->
  @property 'selected'
  
  # @::initialize.doc = 
  #   params: [
  #     ["options", Object, false, default: {}]
  #   ]
  #   desc: """
  #     
  #   """
  def initialize: (options={}) ->
    @property = options.property
    @_super()
    @select undefined
  
  # @::select.doc = 
  #   params: [
  #     ["item", "*", true]
  #   ]
  #   desc: """
  #     
  #   """
  def select: (item) ->
    if @property
      @selected.get()?[@property].set(null)
      item?[@property].set(true)

    @selected.set(item)
