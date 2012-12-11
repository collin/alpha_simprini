(function() {

  module("View");

  test("generates klass strings", function() {
    equal(AS.View["new"]().klassString(), "View", "basic klassString is ASView");
    NS.SomeView = AS.View.extend();
    return equal(NS.SomeView["new"]().klassString(), "View SomeView", "subclasses include parent class string");
  });

  test("builds an element", function() {
    ok(AS.View["new"]().el.is("div"));
    NS.ListView = AS.View.extend(function(_arg) {
      var def;
      def = _arg.def;
      return def({
        tagName: "ol"
      });
    });
    return ok(NS.ListView["new"]().el.is("ol.View.ListView"));
  });

  test("sets options from constructor", function() {
    return equal(AS.View["new"]({
      "this": "that"
    })["this"], "that");
  });

  test("turns Model options into AS.ViewModels", function() {
    var it, view;
    it = AS.Model["new"]();
    view = AS.View["new"]({
      it: it
    });
    return ok(view.it instanceof AS.ViewModel);
  });

  test("has a root binding group", function() {
    return ok(AS.View["new"]().bindingGroup instanceof AS.BindingGroup);
  });

  test("pluralizes text", function() {
    var view;
    view = AS.View["new"]();
    equal(view.pluralize("cat", 4), "cats");
    equal(view.pluralize("person", 0), "people");
    equal(view.pluralize("duck", 1), "duck");
    equal(view.pluralize("duck", -1), "duck");
    return equal(view.pluralize("cat", -4), "cats");
  });

  test("delegates view methods to @el", function() {
    var el, method, methods, view, _i, _len, _results;
    methods = ['addClass', 'removeClass', 'show', 'hide', 'html'];
    expect(methods.length);
    view = AS.View["new"]();
    view.el = el = {};
    _results = [];
    for (_i = 0, _len = methods.length; _i < _len; _i++) {
      method = methods[_i];
      el[method] = function() {
        return ok(true);
      };
      _results.push(view[method]());
    }
    return _results;
  });

  test("allows view element to be set as an option in the constructor", function() {
    var el, view;
    el = $("<div>");
    view = AS.View["new"]({
      el: el
    });
    return equal(el[0], view.currentNode);
  });

  test("stashes childViews", function() {
    return deepEqual([], AS.View["new"]().childViews);
  });

  test("views have a 'view' method to create child views", function() {
    var returned, subEl, view;
    view = AS.View["new"]();
    returned = view.view(AS.View, {
      el: subEl = view.div()
    });
    equal(subEl, returned);
    equal(subEl, view.childViews[0].el[0]);
    return equal(view.childViews[0], view.bindingGroup.children.reverse()[0]);
  });

  module("View.binding()");

  test("creates a binding for a collection", function() {
    var collection, view;
    view = AS.View["new"]();
    collection = AS.Collection["new"]();
    return ok(view.binding(collection, function() {}).constructor === AS.Binding.Many);
  });

  test("creates a binding for a model", function() {
    var model, view;
    view = AS.View["new"]();
    model = AS.Model["new"]();
    return ok(view.binding(model).constructor === AS.Binding.Model);
  });

  module("View.descendantViews()");

  test("returns all descendantViews", function() {
    var view;
    view = AS.View["new"]();
    view.view(AS.View);
    view.childViews[0].view(AS.View);
    return equal(2, view.descendantViews().length);
  });

  test("filters descendantViews by constructor", function() {
    var view;
    NS.SubView = AS.View.extend();
    view = AS.View["new"]();
    view.view(NS.SubView);
    view.childViews[0].view(AS.View);
    return equal(1, view.descendantViews(null, NS.SubView).length);
  });

  module("View Integration: ");

  test("property binding with two children cleans up all content when property changes", function() {
    NS.Parent = AS.Model.extend(function(_arg) {
      var def, defs, delegate, include;
      delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
      return this.property("item");
    });
    NS.Item = AS.Model.extend(function(_arg) {
      var def, defs, delegate, include;
      delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
      return this.hasMany('children', {
        model: function() {
          return NS.Child;
        }
      });
    });
    NS.Child = AS.Model.extend(function(_arg) {
      var def, defs, delegate, include;
      delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
      return this.field('name');
    });
    this.item1 = NS.Item["new"]();
    this.item2 = NS.Item["new"]();
    this.item1.children.add({
      name: "child1"
    });
    this.item1.children.add({
      name: "child2"
    });
    this.item2.children.add({
      name: "child3"
    });
    this.item2.children.add({
      name: "child4"
    });
    this.parent = NS.Parent["new"]({
      item: this.item1
    });
    NS.View = AS.View.extend(function(_arg) {
      var def, defs, delegate, include;
      delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
      return def({
        content: function() {
          var binding;
          return binding = this.parent.binding('item', function(item) {
            this.ol(function() {
              return item.binding('children', function(child) {
                return this.li(function() {
                  return child.binding('name');
                });
              });
            });
            return this.ul(function() {
              return item.binding('children', function(child) {
                return this.li(function() {
                  return child.binding('name');
                });
              });
            });
          });
        }
      });
    });
    this.view = NS.View["new"]({
      parent: this.parent
    });
    equal(2, this.view.el.find("ol li").length, "ordered list items are inserted");
    equal(2, this.view.el.find("ul li").length, "unordered list items are inserted");
    this.parent.item.set(null);
    Taxi.Governer.exit();
    equal(0, this.view.el.find("ol li").length, "ordered list items are removed");
    return equal(0, this.view.el.find("ul li").length, "unordered list items are removed");
  });

  test("property binding nested ina property binding test cleans up bindings", function() {
    var otherBinding;
    NS.Model = AS.Model.extend(function(_arg) {
      var def, defs, delegate, include;
      delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
      this.property("other");
      return this.hasMany("children");
    });
    NS.View = AS.View.extend(function(_arg) {
      var def, defs, delegate, include;
      delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
      return def({
        content: function() {
          return this.root.binding('other', function(other) {
            var binding;
            this.section({
              "class": "root-other",
              id: other.model.objectId()
            }, function() {
              return other.binding('children', function(child) {
                return this.section({
                  id: child.model.objectId()
                });
              });
            });
            return binding = this.model.binding('other', function() {
              return this.section({
                "class": "model-other"
              });
            });
          });
        }
      });
    });
    this.root = NS.Model["new"]();
    this.thing1 = NS.Model["new"]({
      children: [{}]
    });
    this.thing2 = NS.Model["new"]({
      children: [{}, {}]
    });
    this.other1 = NS.Model["new"]();
    this.other2 = NS.Model["new"]();
    this.model = NS.Model["new"]({
      other: this.other1
    });
    this.view = NS.View["new"]({
      root: this.root,
      model: this.model
    });
    otherBinding = NS.OtherBinding;
    this.root.other.set(this.thing1);
    Taxi.Governer.exit();
    ok(this.view.el.find("#" + (this.thing1.objectId())).is("*"), "renders first thing");
    ok(this.view.el.find("#" + (this.thing1.children.at(0).objectId())).is("*"), "renders first thing child");
    this.root.other.set(this.thing2);
    Taxi.Governer.exit();
    ok(this.view.el.find("#" + (this.thing2.objectId())).is("*"), "renders second thing");
    ok(this.view.el.find("#" + (this.thing2.children.at(0).objectId())).is("*"), "renders second thing first child");
    ok(this.view.el.find("#" + (this.thing2.children.at(1).objectId())).is("*"), "renders second thing second child");
    this.model.other.set(this.other2);
    Taxi.Governer.exit();
    equal(1, this.view.el.find(".model-other").length, "renders only one other");
    return ok(this.view.el.find("#" + (this.thing2.objectId())).is("*"), "second thing still visiible");
  });

}).call(this);
