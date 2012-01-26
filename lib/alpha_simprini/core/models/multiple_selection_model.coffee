AS = require "alpha_simprini"
class AS.Models.MultipleSelectionModel extends AS.Model
  @has_many 'selected'

  initialize: ->
    super
    @items = @selected()

    @items.bind "add", (item) => @trigger("add", item)
    @items.bind "remove", (item) => @trigger("remove", item)

  select: (item) ->
    @items.add(item)

  deselect: (item) ->
    @items.remove(item)

  clear: ->
    @items.each @items.remove, @items

