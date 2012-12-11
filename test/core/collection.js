(function() {
  var C;

  C = AS.Namespace["new"]("Collections");

  module("Collection");

  test("sets the inverse is specified", function() {
    var things;
    C.Thing = AS.Model.extend();
    C.Thing.property("inverse");
    C.Thing.property("name");
    C.ThingCollection = AS.Collection.extend(function() {
      this.def({
        model: function() {
          return C.Thing;
        }
      });
      return this.def({
        inverse: "inverse"
      });
    });
    things = C.ThingCollection["new"]();
    things.source = "SOURCE";
    things.add();
    return equal("SOURCE", things.first().value().inverse.get());
  });

  test("clears inverse if specified", function() {
    var thing, things;
    C.Thing = AS.Model.extend();
    C.Thing.property("inverse");
    C.ThingCollection = AS.Collection.extend(function() {
      this.def({
        model: function() {
          return C.Thing;
        }
      });
      return this.def({
        inverse: "inverse"
      });
    });
    things = C.ThingCollection["new"]();
    things.source = "SOURCE";
    thing = things.add();
    things.remove(thing);
    return equal(null, thing.inverse.get());
  });

  test("inserts item of specified type", function() {
    var things;
    C.Thing = AS.Model.extend();
    C.ThingCollection = AS.Collection.extend(function() {
      return this.def({
        model: function() {
          return C.Thing;
        }
      });
    });
    things = C.ThingCollection["new"]();
    things.add();
    return ok(things.first().value() instanceof C.Thing);
  });

  test("inserts item at a specified index", function() {
    var thing, things;
    things = AS.Collection["new"]();
    things.add();
    things.add();
    thing = things.add({}, {
      at: 1
    });
    equal(things.length, 3);
    return equal(things.at(1), thing);
  });

  test("remove item from collection", function() {
    var thing, things;
    things = AS.Collection["new"]();
    thing = things.add();
    things.remove(thing);
    return equal(things.length, 0);
  });

  module("Events");

  test("add event", function() {
    var collection;
    expect(1);
    collection = AS.Collection["new"]();
    collection.bind("add", function() {
      return ok(true);
    });
    collection.add();
    return Taxi.Governer.exit();
  });

  test("remove event", function() {
    var collection, thing;
    expect(1);
    collection = AS.Collection["new"]();
    thing = collection.add();
    collection.bind("remove", function() {
      return ok(true);
    });
    collection.remove(thing);
    return Taxi.Governer.exit();
  });

  test("model change events bubble through collection", function() {
    var collection, thing;
    expect(1);
    C.Thing = AS.Model.extend();
    C.Thing.property("name");
    collection = AS.Collection["new"]();
    thing = collection.add(C.Thing["new"]());
    collection.bind("change", function() {
      return ok(true);
    });
    thing.name.set("changed");
    return Taxi.Governer.exit();
  });

  test("add events capture on collection", function() {
    var collection, thing;
    expect(1);
    thing = AS.Model["new"]();
    collection = AS.Collection["new"]();
    thing.bind("add", function() {
      return ok(true);
    });
    collection.add(thing);
    return Taxi.Governer.exit();
  });

  test("remove events capture on collection", function() {
    var collection, thing;
    expect(1);
    thing = AS.Model["new"]();
    collection = AS.Collection["new"]();
    thing.bind("remove", function() {
      return ok(true);
    });
    collection.add(thing);
    collection.remove(thing);
    return Taxi.Governer.exit();
  });

}).call(this);
