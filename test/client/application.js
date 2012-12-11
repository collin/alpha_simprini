(function() {

  module("Application", {
    setup: function() {
      return this.app = AS.Application["new"]({
        el: this.el = $("<div>")
      });
    }
  });

  test("attaches global key handlers w/jwerty", function() {
    var app, event, events, trigger, triggers, _fn, _i, _j, _len, _len2, _results,
      _this = this;
    events = ["open", "up", "down", "first", "last", "left", "right", "indent", "dedent", "alphanum", "escape", "accept", "delete"];
    app = this.app;
    _fn = function(event) {
      return app.bind(event, function(_event) {
        return ok(_event, "handled " + event);
      });
    };
    for (_i = 0, _len = events.length; _i < _len; _i++) {
      event = events[_i];
      _fn(event);
    }
    triggers = ["esc", "cmd+enter", "backspace", "enter", "up", "down", "home", "end", "left", "right", "tab", "shift+tab", "a", "b", "C", "D", "1", "2"];
    expect(triggers.length);
    _results = [];
    for (_j = 0, _len2 = triggers.length; _j < _len2; _j++) {
      trigger = triggers[_j];
      jwerty.fire(trigger, this.el);
      _results.push(Taxi.Governer.exit());
    }
    return _results;
  });

  test("initializes views into the application context", function() {
    var app_panel;
    app_panel = this.app.view(AS.Views.Panel, {
      key: "value"
    });
    equal(app_panel.application, this.app);
    return equal(app_panel.key, "value");
  });

  test("appends views into the app dom element", function() {
    var app_panel;
    app_panel = this.app.view(AS.Views.Panel, {
      key: "value"
    });
    this.app.append(app_panel);
    return equal(this.app.el.children()[0], app_panel.el[0]);
  });

}).call(this);
