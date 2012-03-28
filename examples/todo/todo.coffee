# #### Alpha Simprini Todo example application.
# The first step is to load Alpha Simprini and the AS `client` module.
# The client module includes the AS.View class and is used to generate
# guis.
AS = require("alpha_simprini")
AS.require("client")


# This module contains Modules and Views.
# More complicated modules might include a Collections object.
Todo = module.exports =
  Models: new Object
  Views: new Object


# ### Todo.Models.List
class Todo.Models.List extends AS.Model
  # The AS.Model.Share mixin adds features from the ShareJS library.
  # The ShareJS integration neccessitates a string path which is used
  # to inflate objects passed in through the ShareJS transport.
  AS.Model.Share.extends(this, "Todo.Models.List")

  # #### Fields
  # The name field is a simple string property with a default value.
  # It's a suitable default name for a list of things to do.
  @field "name", default: "A list of things to do..."

  # #### Relationships
  # When we embed\_many items, we're creating a 1-n relationship between
  # Lists and Items. In coordination with AS.Model.Share, @embeds\_many
  # stores all the embedded models within the same ShareJS document as
  # the list object. If we had used @has\_many, they would be stored in
  # seperate documents with something like a foreign key relation.
  @embeds_many "items", model: -> Todo.Models.Item


  # #### Virtual Properties
  # These virtual properties are similar to computed properties in Ember.js.
  # These particular properties only hinge on one real property, but they
  # could be connected to any number of properties (including other virtual
  # properties.)
  #
  # When the 'items' collection changes, these functions are ran and the reluts
  # are compared to previous values. If the value is different a change event is
  # triggered.
  @virtualProperties "items",
    items_length: ->
      @items().length

    remaining_items_length: ->
      @items().filter((item) -> !item.done()).value().length

    all_done: ->
      @remaining_items_length() is 0

    done_items_length: ->
      @items().filter((item) -> item.done()).value().length

# ### Todo.Models.Item
# These items are embedded within a Todo.Views.List
class Todo.Models.Item extends AS.Model
  AS.Model.Share.extends(this, "Todo.Models.Item")

  @field "task", default: "Something to do..."
  # #### Field types.
  # A field may have a type. This field is a boolean field.
  @field "done", type: Boolean, default: false

# ### Todo.Views.List
class Todo.Views.List extends AS.View
  # #### View Events
  # Similar to Backbone.js View events these events are 'live' bound
  # to the container element for this view.
  # In this case, the jQuery for these events might look like this:
  #
  #     this.el.find(".add_item").live("click", this.add_item)
  #     this.el.find(".remove_item").live("click", this.remove_item)
  #     this.el.find(".clear_items").live("click", this.clear_items)
  #
  events:
    "click .add_item": "add_item"
    "click .remove_item": "remove_item"
    "click .clear_items": "clear_items"

  # #### DOM Generation
  # AlphaSimprini uses pure script to generate DOM.
  # All DOM is appended to a top-level @el. Which defaults to a <div>
  # The tagname may be spetified as:
  #
  #     tag_name: "ul"
  #
  initialize: ->
    # #### editline
    # A special content binding for use in conjuction with
    # AS.Model.Share. It provides a [contenteditable] <span> which is linked
    # "as-you-type" to other active sessions via ShareJS.
    #
    # (We will see later, in the Application initializer, that this view has been
    #  constructed with a Todo.Models.List object. )
    #
    @h1 -> @list.editline "name"

    # This button is bound to the add\_item method through the
    # events: specified at the top of the class.
    @button class: "add_item", -> "Add Item"

    @label ->
      # #### Field/Property/Relation Binding
      # Calling binding with field, virtual\_property, or relation name creates
      # the appropriate databinding in the DOM. Here a function is used to specify
      # the content in the binding. As 'all\_done' is a virtual property the contents
      # of this binding will be redrawn whenever the value of the property changes.
      @list.binding "all_done", ->
        # #### Checkbox Binding
        # Binds the value of 'all\_done' to a checkbox. This binding is two-way. Changing
        # the value of the checkbox changes the value on the model.
        # (TODO: At this moment the implementation of setting virtual properties is non-existent.
        # clicking this checkbox will not effect the underlying data.)
        @list.checkbox("all_done")
        if @list.all_done()
          @text  "Mark all as incomplete"
        else
          @text "Mark all as complete"

    # The listing method encapsulates and makes reusable the code to display a list
    # Items in the List.
    @listing "Things to do:", done: false
    @listing "Things I've done:", done: true

    @footer ->
      @span ->
        @list.binding "remaining_items_length", =>
          count = @list.remaining_items_length()
          @span "#{count} more #{@pluralize("thing", count)} to do!"

      @span ->
        @list.binding "done_items_length", =>
          count = @list.done_items_length()
          return "" if count is 0
          @button class: "clear_items", ->
            "Clear #{count} completed #{@pluralize('item', count)}."

  # The listing "partial"
  listing: (label, filter) ->
    @h2 label
    @ul ->
      # #### Filtering Relation bindings.
      # When binding to a collection (@has\_many or @embeds\_many), you may
      # provide a filter. In this case the filter will be on the 'done' property.
      # Items matching the filter will be excluded from the view. As an item's fields
      # and properties change it will be refiltered and possibly displayed in this binding.
      @list.binding "items", filter: filter, (item) ->
        @li ->
          item.checkbox("done")
          @p -> item.editline("task")
          button = @button class: "remove_item", -> "x"
          @$(button).data().item = item

  # ### View Methods
  # These are the methods bound in the events property at the top of the class.
  # While application state changes the View will be redrawn as warranted.
  add_item: (item) ->
    @list.items().add new Todo.Models.Item

  remove_item: (event) ->
    @list.items().remove @$(event.currentTarget).data().item

  clear_items: (event) ->
    items = @list.items()
    items.each (item) => items.remove(item) if item.done()

# ### Todo.Application
class Todo.Application extends AS.Application
  # Because we are using ShareJS, we must "open" our List object and bind to the "ready"
  # event. The @params are set on the Todo namespace and passed onto the @params field
  # at application initialization time.
  #
  #     Todo.params = {list_id: "some list"};
  #     Todo.app = new Todo.Application()
  #
  initialize: ->
    @list = Todo.Models.List.shared(@params.list_id)
    @list.bind "ready", @listready, this

  # When the list is ready we create the view and pass in the list.
  # Then the list view is appended to the application and we're good to go.
  listready: ->
    @list_view = @view Todo.Views.List, list: @list
    @append @list_view

