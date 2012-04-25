AS = require "alpha_simprini"
AS.Models.MultipleSelectionModel = AS.Model.extend ({def}) ->
  @hasMany "items"

  # @::initialize.doc =
  #   desc: """
  #
  #   """
  def initialize: ->
    @_super()

    @items.bind "add", (item) => @trigger("add", item)
    @items.bind "remove", (item) => @trigger("remove", item)

  # @::select.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """
  def select: (item) ->
    @items.add(item)

  # @::deselect.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """
  def deselect: (item) ->
    @items.remove(item)

  # @::clear.doc =
  #   desc: """
  #
  #   """
  def clear: ->
    @items.each @items.remove, @items
