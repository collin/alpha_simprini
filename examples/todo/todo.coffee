AS = require "alpha_simprini"
AS.require("client")

require("jquery") ->
  require("rangy-core")
  rangy.init()

Todo = module.exports =
  Models: {}
  Views: {}

AS.sharejs_url = "http://localhost:3210/sjs"
  
class Todo.Models.List extends AS.Model
  AS.Model.Share.extends(this)
  @_type = "Todo.Models.List"
  
  @field "name"
  @embeds_many "items", model: -> Todo.Models.Item
  
  initialize: ->
    super
    @name "A list of things to do..." unless @name()
  
class Todo.Models.Item extends AS.Model
  AS.Model.Share.extends(this)
  @_type = "Todo.Models.Item"
  
  @field "task"
  @field "done"
  
  initialize: ->
    super
    @done false
    @task() or @task "Something to do..."

  done: (value, options={}) ->
    if value is undefined
      attr = @get_attribute("done")
      !!(attr is true or attr is "true")
    else
      @set_attribute("done", value, options)

class Todo.Views.List extends AS.View
  events:
    "click .add_item": "add_item"
    "click .remove_item": "remove_item"
    
  initialize: ->
    @h1 ->
      @list.binding "name"
    
    @button class: "add_item", -> "Add Item"
    
    @h2 "Things to do:"
    @ul -> @list.binding "items", filter: {done: false}, (item) ->
      @li -> @display_item(item)

    @h2 "Things I've done:"
    @ul -> @list.binding "items", filter: (done: true), (item) ->
      @li -> @display_item(item)
  
  add_item: (item) ->
    @list.items().add new Todo.Models.Item
  
  remove_item: (event) ->
    @list.items().remove @$(event.currentTarget).data().item.model

  display_item: (item) ->
    item.checkbox("done")
    @p -> item.editline("task")
    button = @button class: "remove_item", -> "x"
    @$(button).data().item = item
    
class Todo.Application extends AS.Application
  initialize: ->
    @list = Todo.Models.List.open(@params.list_id)
    @list.bind "ready", @listready, this
  
  listready: ->
    @list_view = @view Todo.Views.List, list: @list
    @append @list_view
