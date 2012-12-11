(function() {

  module("ViewEvents");

  test("delegates events", function() {
    var BoundView, view;
    expect(3);
    BoundView = AS.View.extend(function(_arg) {
      var def;
      def = _arg.def;
      def({
        events: {
          "click": "click_handler",
          "click button": "button_handler",
          "event @member": "member_handler"
        }
      });
      def({
        initialize: function() {
          this.member = AS.Model["new"]();
          this._super.apply(this, arguments);
          return this._button = this.$(this.button());
        }
      });
      def({
        click_handler: function() {
          return ok(true);
        }
      });
      def({
        member_handler: function() {
          return ok(true);
        }
      });
      def({
        button_handler: function() {
          return ok(true);
        }
      });
      def({
        guard_fail_handler: function() {
          return ok(true);
        }
      });
      return def({
        guard_pass_handler: function() {
          return ok(true);
        }
      });
    });
    view = BoundView["new"]();
    view.member.trigger("event");
    Taxi.Governer.exit();
    return view._button.trigger("click");
  });

}).call(this);
