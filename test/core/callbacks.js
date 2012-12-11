(function() {
  var WithCallbacks;

  WithCallbacks = AS.Object.extend(function(_arg) {
    var include;
    include = _arg.include;
    include(AS.Callbacks);
    return this.defineCallbacks({
      before: "this that".split(" ")
    });
  });

  module("Callbacks");

  test("definition", function() {
    var it;
    it = WithCallbacks;
    ok(WithCallbacks.beforeThis);
    return ok(WithCallbacks.beforeThat);
  });

  test("running", function() {
    var cb, it, one;
    expect(2);
    it = WithCallbacks;
    cb = function() {
      return ok(true);
    };
    it.beforeThis(cb);
    it.beforeThat(cb);
    one = WithCallbacks["new"]();
    one.runCallbacks("beforeThis");
    return one.runCallbacks("beforeThat");
  });

}).call(this);
