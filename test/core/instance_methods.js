(function() {
  var __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  module("InstanceMethods");

  test("discoversInstanceMethods", function() {
    var HasMethods;
    HasMethods = AS.Object.extend(function(_arg) {
      var def;
      def = _arg.def;
      def({
        a: 1
      });
      return def({
        b: 2
      });
    });
    ok(__indexOf.call(AS.instanceMethods(HasMethods), "a") >= 0);
    return ok(__indexOf.call(AS.instanceMethods(HasMethods), "b") >= 0);
  });

  test("traversesClasses", function() {
    var A, B;
    A = AS.Object.extend(function(_arg) {
      var def;
      def = _arg.def;
      return def({
        a: 1
      });
    });
    B = A.extend(function(_arg) {
      var def;
      def = _arg.def;
      return def({
        b: 2
      });
    });
    ok(__indexOf.call(AS.instanceMethods(B), "a") >= 0);
    return ok(__indexOf.call(AS.instanceMethods(B), "b") >= 0);
  });

}).call(this);
