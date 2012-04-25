{AS, $, _, sinon, NS} = require require("path").resolve("./test/client_helper")
exports.View =
  "generates klass strings": (test) ->
    test.equal AS.View.new().klassString(), "View", "basic klassString is ASView"

    NS.SomeView = AS.View.extend()

    test.equal NS.SomeView.new().klassString(), "View SomeView", "subclasses include parent class string"

    test.done()

  "builds an element": (test) ->
    test.ok AS.View.new().el.is("div")
    NS.ListView = AS.View.extend ({def}) ->
      def tagName: "ol"

    test.ok NS.ListView.new().el.is("ol.View.ListView")
    test.done()

  "sets options from constructor": (test) ->
    test.equal AS.View.new(this: "that").this, "that"
    test.done()

  "turns Model options into AS.ViewModels": (test) ->
    it = AS.Model.new()
    view = AS.View.new(it:it)
    test.ok view.it instanceof AS.ViewModel
    test.done()

  "has a root binding group": (test) ->
    test.ok AS.View.new().bindingGroup instanceof AS.BindingGroup
    test.done()

  "pluralizes text": (test) ->
    view = AS.View.new()
    test.equal view.pluralize("cat", 4), "cats"
    test.equal view.pluralize("person", 0), "people"
    test.equal view.pluralize("duck", 1), "duck"
    test.equal view.pluralize("duck", -1), "duck"
    test.equal view.pluralize("cat", -4), "cats"
    test.done()

  "delegates view methods to @el": (test) ->
    methods = ['addClass', 'removeClass', 'show', 'hide', 'html']
    test.expect methods.length
    view = AS.View.new()
    view.el = el = {}

    for method in methods
      el[method] = -> test.ok(true)
      view[method]()

    test.done()

  "allows view element to be set as an option in the constructor": (test) ->
    el = $("<div>")
    view = AS.View.new(el:el)
    test.equal el[0], view.currentNode
    test.done()

  "stashes childViews": (test) ->
    test.deepEqual [], AS.View.new().childViews
    test.done()

  "views have a 'view' method to create child views": (test) ->
    view = AS.View.new()
    returned = view.view AS.View, el: subEl = view.div()
    test.equal subEl, returned
    test.equal subEl, view.childViews[0].el[0]

    # child view is added to the bindingGroup's children so 'unbind'
    # will be called on the view object.
    test.equal view.childViews[0], view.bindingGroup.children.reverse()[0]

    test.done()

  # "when view is unbound it is removed from it's parents childViews and from the DOM": (test) ->
  #   view = AS.View.new()
  #   view.view(AS.View, el: view.div(-> @h1()))
  #   view.bindingGroup.unbind()
  #   test.deepEqual [], view.childViews
  #   test.equal "", view.html()
  #   test.done()

  "binding()":
    "creates a binding for a collection": (test) ->
      view = AS.View.new()
      collection = AS.Collection.new()
      test.ok view.binding(collection, ->).constructor is AS.Binding.Many
      test.done()

    "creates a binding for a model": (test) ->
      view = AS.View.new()
      model = AS.Model.new()
      test.ok view.binding(model).constructor is AS.Binding.Model
      test.done()


  "descendantViews()":
    "returns all descendantViews": (test) ->
      view = AS.View.new()
      view.view AS.View
      view.childViews[0].view AS.View

      test.equal 2, view.descendantViews().length
      test.done()

    "filters descendantViews by constructor": (test) ->
      NS.SubView = AS.View.extend()
      view = AS.View.new()
      view.view NS.SubView
      view.childViews[0].view AS.View

      test.equal 1, view.descendantViews(null, NS.SubView).length
      test.done()

exports["View Integration"] =
  "property binding with two children":
    setUp: (callback) ->
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
      callback()

    "cleans up all content when property changes": (test) ->
      test.equal 2, @view.el.find("ol li").length
      test.equal 2, @view.el.find("ul li").length
      @parent.item.set(null)
      test.equal 0, @view.el.find("ol li").length
      test.equal 0, @view.el.find("ul li").length
      test.done()

  "property binding nested ina property binding":
    setUp: (callback) ->
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

      callback()

    "cleans up bindings": (test) ->
      otherBinding = NS.OtherBinding

      @root.other.set(@thing1)
      test.ok @view.el.find("##{@thing1.objectId()}").is("*"), "renders first thing"
      test.ok @view.el.find("##{@thing1.children.at(0).objectId()}").is("*"), "renders first thing child"

      @root.other.set(@thing2)
      test.ok @view.el.find("##{@thing2.objectId()}").is("*"), "renders second thing"
      test.ok @view.el.find("##{@thing2.children.at(0).objectId()}").is("*"), "renders second thing first child"
      test.ok @view.el.find("##{@thing2.children.at(1).objectId()}").is("*"), "renders second thing second child"

      @model.other.set(@other2)

      test.equal 1, @view.el.find(".model-other").length, "renders only one other"
      test.ok @view.el.find("##{@thing2.objectId()}").is("*"), "second thing still visiible"
      test.done()
