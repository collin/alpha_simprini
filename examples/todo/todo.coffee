AS = require "alpha_simprini"
AS.require("client")

Todo = module.exports =
  Models: new Object
  Views: new Object

class Todo.Models.List extends AS.Model
  AS.Model.Share.extends(this, "Todo.Models.List")

  @field "name", default: "A list of things to do..."

class Todo.Models.Item extends AS.Model
  AS.Model.Share.extends(this, "Todo.Models.Item")

  @field "task", default: "Something to do..."
  @field "done", type: Boolean, default: false

class Todo.Views.List extends AS.VIew
  events:
    "click .add_item": "add_item"
    "click .remove_item": "remove_item"
  
  initialize: ->
    @h1 -> @list.editline "name"

    @button class: "add_item", -> "Add Item"
    
    @list "Things to do:", done: false
    @list "Things I've done:", done: true

  
  list: (label, filter) ->
    @h2 label
    @ul -> @list.binding "items", filter: filter, (item) -> @li
      item.checkbox("done")
      @p -> item.editline("task")
      @$(@button class: "remove_item", -> "x").data().item = item

class Todo.Application extends AS.Application
  initialize: ->
    @list = Todo.Models.List.open(@params.list_id)
    @list.bind "ready", @listready, this
  
  listready: ->
    @append @list_view = @view Todo.Views.List list: @list
