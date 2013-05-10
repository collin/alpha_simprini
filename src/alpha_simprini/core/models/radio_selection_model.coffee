class AS.Models.RadioSelectionModel < AS.Model
  @belongsTo 'selected', remote:false
  @field '_property', remote:false

  def initialize: (options={}) ->
    property = options.property
    delete options.property
    @_super.apply(this, arguments)
    @_property.set property if property
    @select undefined
  # @::initialize.doc =
  #   params: [
  #     ["options", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def select: (item) ->
    property = @_property.get()
    if property
      @selected.get()?.model[property]?.set(false)
      item?.model[property]?.set(true)

    @selected.set(item)
  # @::select.doc =
  #   params: [
  #     ["item", "*", true]
  #   ]
  #   desc: """
  #
  #   """
