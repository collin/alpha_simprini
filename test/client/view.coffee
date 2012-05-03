module "View"
test "generates klass strings", ->
  equal AS.View.new().klassString(), "View", "basic klassString is ASView"

  NS.SomeView = AS.View.extend()

  equal NS.SomeView.new().klassString(), "View SomeView", "subclasses include parent class string"


test "builds an element", ->
  ok AS.View.new().el.is("div")
  NS.ListView = AS.View.extend ({def}) ->
    def tagName: "ol"

  ok NS.ListView.new().el.is("ol.View.ListView")

test "sets options from constructor", ->
  equal AS.View.new(this: "that").this, "that"

test "turns Model options into AS.ViewModels", ->
  it = AS.Model.new()
  view = AS.View.new(it:it)
  ok view.it instanceof AS.ViewModel

test "has a root binding group", ->
  ok AS.View.new().bindingGroup instanceof AS.BindingGroup

test "pluralizes text", ->
  view = AS.View.new()
  equal view.pluralize("cat", 4), "cats"
  equal view.pluralize("person", 0), "people"
  equal view.pluralize("duck", 1), "duck"
  equal view.pluralize("duck", -1), "duck"
  equal view.pluralize("cat", -4), "cats"

test "delegates view methods to @el", ->
  methods = ['addClass', 'removeClass', 'show', 'hide', 'html']
  expect methods.length
  view = AS.View.new()
  view.el = el = {}

  for method in methods
    el[method] = -> ok(true)
    view[method]()


test "allows view element to be set as an option in the constructor", ->
  el = $("<div>")
  view = AS.View.new(el:el)
  equal el[0], view.currentNode

test "stashes childViews", ->
  deepEqual [], AS.View.new().childViews

test "views have a 'view' method to create child views", ->
  view = AS.View.new()
  returned = view.view AS.View, el: subEl = view.div()
  equal subEl, returned
  equal subEl, view.childViews[0].el[0]

  # child view is added to the bindingGroup's children so 'unbind'
  # will be called on the view object.
  equal view.childViews[0], view.bindingGroup.children.reverse()[0]


# "when view is unbound it is removed from it's parents childViews and from the DOM", ->
#   view = AS.View.new()
#   view.view(AS.View, el: view.div(-> @h1()))
#   view.bindingGroup.unbind()
#   deepEqual [], view.childViews
#   equal "", view.html()
#

module "View.binding()"
test "creates a binding for a collection", ->
  view = AS.View.new()
  collection = AS.Collection.new()
  ok view.binding(collection, ->).constructor is AS.Binding.Many

test "creates a binding for a model", ->
  view = AS.View.new()
  model = AS.Model.new()
  ok view.binding(model).constructor is AS.Binding.Model


module "View.descendantViews()"
test "returns all descendantViews", ->
  view = AS.View.new()
  view.view AS.View
  view.childViews[0].view AS.View

  equal 2, view.descendantViews().length

test "filters descendantViews by constructor", ->
  NS.SubView = AS.View.extend()
  view = AS.View.new()
  view.view NS.SubView
  view.childViews[0].view AS.View

  equal 1, view.descendantViews(null, NS.SubView).length

module "View Integration: "
test "property binding with two children cleans up all content when property changes", ->
  NS.Parent = AS.Model.extend ({delegate, include, def, defs}) ->
    @property "item"

  NS.Item = AS.Model.extend ({delegate, include, def, defs}) ->
    @hasMany 'children', model: -> NS.Child

  NS.Child = AS.Model.extend ({delegate, include, def, defs}) ->
    @field 'name'


  @item1 = NS.Item.new()
  @item2 = NS.Item.new()

  @item1.children.add name: "child1"
  @item1.children.add name: "child2"

  @item2.children.add name: "child3"
  @item2.children.add name: "child4"

  @parent = NS.Parent.new(item: @item1)

  NS.View = AS.View.extend ({delegate, include, def, defs}) ->
    def content: ->
      binding = @parent.binding 'item', (item) ->
        @ol ->
          item.binding 'children', (child) ->
            @li -> child.binding 'name'
        @ul ->
          item.binding 'children', (child) ->
            @li -> child.binding 'name'

  @view = NS.View.new(parent: @parent)
  equal 2, @view.el.find("ol li").length
  equal 2, @view.el.find("ul li").length
  @parent.item.set(null)
  equal 0, @view.el.find("ol li").length
  equal 0, @view.el.find("ul li").length

test "property binding nested ina property binding test cleans up bindings", ->
  NS.Model = AS.Model.extend ({delegate, include, def, defs}) ->
    @property "other"
    @hasMany "children"

  NS.View = AS.View.extend ({delegate, include, def, defs}) ->
    def content: ->
      @root.binding 'other', (other) ->
        @section class: "root-other", id:other.model.objectId(), ->
          other.binding 'children', (child) ->
            @section id: child.model.objectId()

        binding = @model.binding 'other', ->
          @section class:"model-other"

  @root = NS.Model.new()

  @thing1 = NS.Model.new children: [{}]
  @thing2 = NS.Model.new  children: [{}, {}]

  @other1 = NS.Model.new()
  @other2 = NS.Model.new()
  @model = NS.Model.new(other: @other1)

  @view = NS.View.new(root: @root, model: @model)

  otherBinding = NS.OtherBinding

  @root.other.set(@thing1)
  ok @view.el.find("##{@thing1.objectId()}").is("*"), "renders first thing"
  ok @view.el.find("##{@thing1.children.at(0).objectId()}").is("*"), "renders first thing child"

  @root.other.set(@thing2)
  ok @view.el.find("##{@thing2.objectId()}").is("*"), "renders second thing"
  ok @view.el.find("##{@thing2.children.at(0).objectId()}").is("*"), "renders second thing first child"
  ok @view.el.find("##{@thing2.children.at(1).objectId()}").is("*"), "renders second thing second child"

  @model.other.set(@other2)

  equal 1, @view.el.find(".model-other").length, "renders only one other"
  ok @view.el.find("##{@thing2.objectId()}").is("*"), "second thing still visiible"
  