AS.Models.MultipleSelectionModel = AS.Model.extend ({def}) ->
  @hasMany "items"

  def initialize: ->
    @_super()

    @items.bind "add", (item) => @trigger("add", item)
    @items.bind "remove", (item) => @trigger("remove", item)
  # @::initialize.doc =
  #   desc: """
  #
  #   """

  def select: (item) ->
    @items.add(item)
  # @::select.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  def deselect: (item) ->
    @items.remove(item)
  # @::deselect.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  def clear: ->
    @items.each @items.remove, @items
  # @::clear.doc =
  #   desc: """
  #
  #   """
