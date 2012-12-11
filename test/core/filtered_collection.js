(function() {
  var C;

  C = AS.Namespace["new"]("Collections");

  C.Model = AS.Model.extend(function(_arg) {
    var def, defs, delegate, include;
    delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
    return this.field("truth", {
      type: AS.Model.Boolean,
      "default": false
    });
  });

  C.Collection = AS.Collection.extend(function(_arg) {
    var def, defs, delegate, include;
    delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
  });

  module("FilteredCollection");

  test("by default, all members are in the filtered collection", function() {
    var c, f, one, three, two;
    c = C.Collection["new"]();
    f = c.filter();
    one = c.add(C.Model["new"]());
    two = c.add(C.Model["new"]());
    three = c.add(C.Model["new"]());
    Taxi.Governer.exit();
    return deepEqual(f.models.value(), [one, two, three]);
  });

  test("removes items from filter when they are removed from collection", function() {
    var c, f, one, three, two;
    c = C.Collection["new"]();
    f = c.filter();
    one = c.add(C.Model["new"]());
    two = c.add(C.Model["new"]());
    three = c.add(C.Model["new"]());
    c.remove(two);
    Taxi.Governer.exit();
    return deepEqual(f.models.value(), [one, three]);
  });

  test("respects filter function when adding models", function() {
    var c, f, one, three, two;
    c = C.Collection["new"]();
    f = c.filter({
      truth: false
    });
    one = c.add(C.Model["new"]());
    two = c.add(C.Model["new"]({
      truth: true
    }));
    three = c.add(C.Model["new"]());
    Taxi.Governer.exit();
    return deepEqual(f.models.value(), [one, three]);
  });

  test("add filtered items when they change", function() {
    var c, f, one, three, two;
    c = C.Collection["new"]();
    f = c.filter({
      truth: false
    });
    one = c.add(C.Model["new"]());
    two = c.add(C.Model["new"]({
      truth: true
    }));
    three = c.add(C.Model["new"]());
    two.truth.set(false);
    Taxi.Governer.exit();
    return deepEqual(f.models.pluck('id').sort().value(), _([one, three, two]).pluck("id").sort());
  });

  test("remove filtered items when they change", function() {
    var c, f, one, three, two;
    c = C.Collection["new"]();
    f = c.filter({
      truth: false
    });
    one = c.add(C.Model["new"]());
    two = c.add(C.Model["new"]());
    three = c.add(C.Model["new"]());
    two.truth.set(true);
    Taxi.Governer.exit();
    return deepEqual(f.models.value(), [one, three]);
  });

  test("triggers add/remove events", function() {
    var c, f, one, three, two;
    expect(5);
    c = C.Collection["new"]();
    f = c.filter({
      truth: false
    });
    f.bind("add", function() {
      return ok(true);
    });
    f.bind("remove", function() {
      return ok(true);
    });
    one = c.add(C.Model["new"]());
    Taxi.Governer.exit();
    two = c.add(C.Model["new"]({
      truth: true
    }));
    Taxi.Governer.exit();
    three = c.add(C.Model["new"]());
    Taxi.Governer.exit();
    two.truth.set(false);
    Taxi.Governer.exit();
    two.truth.set(true);
    Taxi.Governer.exit();
    return deepEqual(f.models.pluck('id').value(), [one.id, three.id]);
  });

  test("re-filters when filter changes", function() {
    var c, f, one, three, two;
    c = C.Collection["new"]();
    f = c.filter({
      truth: false
    });
    one = c.add(C.Model["new"]());
    two = c.add(C.Model["new"]({
      truth: true
    }));
    three = c.add(C.Model["new"]());
    f.setConditions({
      truth: true
    });
    Taxi.Governer.exit();
    return deepEqual(f.models.value(), [two]);
  });

}).call(this);
