AS = require "alpha_simprini"
AS.require("client")

Todo = module.exports =
  Models: new Object
  Views: new Object

class Todo.Models.List extends AS.Model
  AS.Model.Share.extends(this, "Todo.Models.List")

  @field "name", default: "A list of things to do..."
  @embeds_many "items", model: -> Todo.Models.Item,
  
  @virtual_properties "items", 
    items_length: -> 
      @items().length

    all_done: ->
      @done_items_length is 0

    done_items_length: ->
      @items().findAll((item) -> !item.done()).length

    remaining_items_length: ->
      @items().findAll((item) -> item.done()).length
  
class Todo.Models.Item extends AS.Model
  AS.Model.Share.extends(this, "Todo.Models.Item")

  @field "task", default: "Something to do..."
  @field "done", type: Boolean, default: false

class Todo.Views.List extends AS.View
  events:
    "click .add_item": "add_item"
    "click .remove_item": "remove_item"
    "click .clear_items": "clear_items"
  
  initialize: ->
    @h1 -> @list.editline "name"

    @button class: "add_item", -> "Add Item"
    
    @label
      @list.checkbox("all_done")
      @list.binding "all_done", ->
        if @list.all_done()
          @text  "Mark all as incomplete"
        else
          @text "Mark all as complete"
    
    @listing "Things to do:", done: false
    @listing "Things I've done:", done: true

    @footer ->
      @list.binding "remaining_items_length", (count) ->
        @span "#{count} #{@pluralize("item", count)} left"
      
      @list.binding "done_items_length", (count) ->
        return if count is 0
        @button class: "clear_items", ->
          "Clear #{count} completed #{@pluralize("item", count).}"
      
  listing: (label, filter) ->
    @h2 label
    @ul -> 
      @list.binding "items", filter: filter, (item) ->
        @li ->
          item.checkbox("done")
          @p -> item.editline("task")
          button = @button class: "remove_item", -> "x"
          @$(button).data().item = item

  add_item: (item) ->
    @list.items().add new Todo.Models.Item
  
  remove_item: (event) ->
    @list.items().remove @$(event.currentTarget).data().item

  clear_items: (event) ->
    @list.each (item) => @list.remove(item) if item.done()

class Todo.Application extends AS.Application
  initialize: ->
    @list = Todo.Models.List.open(@params.list_id)
    @list.bind "ready", @listready, this
  
  listready: ->
    @list_view = @view Todo.Views.List, list: @list
    @append @list_view
