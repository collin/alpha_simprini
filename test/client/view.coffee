{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
exports.View =
  "generates klass strings": (test) ->
    test.equal new AS.View().klass_string(), "", "basic klass_string is ASView"

    class SomeView extends AS.View

    test.equal new SomeView().klass_string(), "SomeView", "subclasses include parent class string"

    test.done()

  "builds an element": (test) ->
    test.ok (new AS.View).el.is("div")
    class ListView extends AS.View
      tag_name: "ol"
    test.ok (new ListView).el.is("ol")
    test.done()

  "sets options from constructor": (test) ->
    test.equal (new AS.View this: "that").this, "that"
    test.done()

  "turns Model options into ASViewModels": (test) ->
    test.ok (new AS.View it: new AS.Model).it instanceof AS.ViewModel
    test.done()

  "has a root binding group": (test) ->
    test.ok (new AS.View).binding_group instanceof AS.BindingGroup
    test.done()

  "pluralizes text": (test) ->
    view = new AS.View
    test.equal view.pluralize("cat", 4), "cats"
    test.equal view.pluralize("person", 0), "people"
    test.equal view.pluralize("duck", 1), "duck"
    test.equal view.pluralize("duck", -1), "duck"
    test.equal view.pluralize("cat", -4), "cats"
    test.done()
