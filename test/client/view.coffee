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

  "when view is unbound it is removed from it's parents childViews and from the DOM": (test) ->
    view = AS.View.new()
    view.view(AS.View, el: view.div(-> @h1()))
    view.bindingGroup.unbind()
    test.deepEqual [], view.childViews
    test.equal "", view.html()
    test.done()

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

