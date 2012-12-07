class AS.Models.MultipleSelectionModel < AS.Model
  @hasMany "items"

  def initialize: (options={}) ->
    @property = options.property

    @_super()

    @items.bind "add", (item) => @trigger("add", item)
    @items.bind "remove", (item) => @trigger("remove", item)
  # @::initialize.doc =
  #   desc: """
  #
  #   """

  def select: (item) ->
    item[@property]?.set(true) if @property

    @items.add(item)
  # @::select.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  def deselect: (item) ->
    item[@property]?.set(null) if @property

    @items.remove(item)
  # @::deselect.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  def clear: ->
    @items.each (item) =>
      @items.remove(item)
      item[@property]?.set(null) if @property

  # @::clear.doc =
  #   desc: """
  #
  #   """
