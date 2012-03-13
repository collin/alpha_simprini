{AS, $, _, sinon, NS} = require require("path").resolve("./test/client_helper")
exports.View =
  "generates klass strings": (test) ->
    test.equal AS.View.new().klassString(), "AlphaSimprini View", "basic klassString is ASView"

    NS.SomeView = AS.View.extend()

    test.equal NS.SomeView.new().klassString(), "NS SomeView", "subclasses include parent class string"

    test.done()

  "builds an element": (test) ->
    test.ok AS.View.new().el.is("div")
    NS.ListView = AS.View.extend ({def}) ->
      def tagName: "ol"

    test.ok NS.ListView.new().el.is("ol.NS.ListView")
    test.done()

  "sets options from constructor": (test) ->
    test.equal AS.View.new(this: "that").this, "that"
    test.done()

  "turns Model options into ASViewModels": (test) ->
    test.ok AS.View.new(it: new AS.Model).it instanceof AS.ViewModel
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
