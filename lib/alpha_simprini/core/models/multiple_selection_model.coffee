# AS = require "alpha_simprini"
# AS.Models.MultipleSelectionModel = AS.Model.extend ({def}) ->
#   @hasMany "items"

#   def initialize: ->
#     @_super()
#     @items = @selected()

#     @items.bind "add", (item) => @trigger("add", item)
#     @items.bind "remove", (item) => @trigger("remove", item)

#   def select: (item) ->
#     @items.add(item)

#   def deselect: (item) ->
#     @items.remove(item)

#   def clear: ->
#     @items.each @items.remove, @items
