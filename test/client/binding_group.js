(function() {

  module("BindingGroup");

  test("has a unique namespace", function() {
    var bg1, bg2;
    bg1 = AS.BindingGroup["new"]();
    bg2 = AS.BindingGroup["new"]();
    notEqual(bg1.namespace, bg2.namespace);
    return equal(bg1.namespace[0], "b");
  });

  test("binds to jquery objects", function() {
    var bg, object;
    expect(1);
    bg = AS.BindingGroup["new"]();
    object = $("<target>");
    bg.binds(object, "event", function() {
      return ok(true);
    });
    return object.trigger("event");
  });

  test("binds to AS.Event event model", function() {
    var bg, object, _handler;
    expect(4);
    bg = AS.BindingGroup["new"]();
    _handler = function() {
      return "value";
    };
    object = {
      bind: function(_arg) {
        var context, event, handler, namespace;
        event = _arg.event, namespace = _arg.namespace, handler = _arg.handler, context = _arg.context;
        equal(event, "event");
        equal(namespace, bg.namespace);
        equal(_handler(), "value");
        return equal(context, object);
      }
    };
    return bg.binds(object, "event", _handler, object);
  });

  test("unbinds bound objects", function() {
    var bg, handler, object;
    expect(1);
    bg = AS.BindingGroup["new"]();
    object = {
      bind: function() {},
      unbind: function(namespace) {
        return equal(namespace, "." + bg.namespace);
      }
    };
    handler = function() {};
    bg.binds(object, "event", handler, object);
    return bg.unbind();
  });

  test("unbinds bound objects in nested binding groups", function() {
    var child, handler, object, parent;
    parent = AS.BindingGroup["new"]();
    child = parent.addChild();
    object = {
      bind: function() {},
      unbind: function(namespace) {
        return equal(namespace, "." + child.namespace);
      }
    };
    handler = function() {};
    child.binds(object, "event", handler, object);
    return parent.unbind();
  });

}).call(this);
