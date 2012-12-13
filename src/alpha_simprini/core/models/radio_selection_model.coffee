class AS.Models.RadioSelectionModel < AS.Model
  @belongsTo 'selected', remote:false

  def initialize: (options={}) ->
    @property = options.property
    delete options.property
    @_super.apply(this, arguments)
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
      @selected.get()?.model[@property]?.set(null)
      item?.model[@property]?.set(true)

    @selected.set(item)
  # @::select.doc =
  #   params: [
  #     ["item", "*", true]
  #   ]
  #   desc: """
  #
  #   """
