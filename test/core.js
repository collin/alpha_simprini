(function() {

  module("utilities");

  test("testIdentity", function() {
    return ok(AS.Identity(10)(10));
  });

  test("constructorIdentity", function() {
    var Fake;
    Fake = (function() {

      function Fake() {}

      return Fake;

    })();
    return ok(AS.ConstructorIdentity(Fake)(new Fake));
  });

  test("deepClone", function() {
    var it, not_it;
    notEqual(AS.deepClone(it = []), it);
    notEqual(AS.deepClone(it = {}), it);
    deepEqual(AS.deepClone(it = []), it);
    deepEqual(AS.deepClone(it = {}), it);
    it = [
      {
        a: 134,
        3: [2, {}, [], [], "FOO"]
      }, 23, "BAR"
    ];
    deepEqual(AS.deepClone(it), it);
    not_it = AS.deepClone(it);
    not_it.push("BAZ");
    return notDeepEqual(it, not_it);
  });

  test("uniq", function() {
    ok(AS.uniq().match(/^\w+$/));
    return notEqual(AS.uniq(), AS.uniq());
  });

  test("humanSize", function() {
    var index, prefix, sz, _len, _ref, _results;
    sz = AS.humanSize;
    equal(sz(100), "100.0 B");
    _ref = ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    _results = [];
    for (index = 0, _len = _ref.length; index < _len; index++) {
      prefix = _ref[index];
      _results.push(equal(sz(Math.pow(1024, index + 1)), "1.0 " + prefix));
    }
    return _results;
  });

}).call(this);
