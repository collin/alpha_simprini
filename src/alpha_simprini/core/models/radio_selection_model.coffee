AS.Models.RadioSelectionModel = AS.Model.extend ({def}) ->
  @property 'selected'

  def initialize: (options={}) ->
    @property = options.property
    @_super()
    @select undefined
  # @::initialize.doc =
  #   params: [
  #     ["options", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def select: (item) ->
    if @property
      @selected.get()?[@property].set(null)
      item?[@property].set(true)

    @selected.set(item)
  # @::select.doc =
  #   params: [
  #     ["item", "*", true]
  #   ]
  #   desc: """
  #
  #   """
