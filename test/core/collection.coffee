{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

C = AS.Namespace.new("Collections")

exports.Collection =
  "sets the inverse is specified": (test) ->
    C.Thing = AS.Model.extend()
    C.Thing.property("inverse")
    C.Thing.property("name")
    C.ThingCollection = AS.Collection.extend ->
      @def model: -> C.Thing
      @def inverse: "inverse"

    things = C.ThingCollection.new()
    things.source = "SOURCE"
    things.add()

    test.equal "SOURCE", things.first().value().inverse.get()
    test.done()

  "clears inverse if specified": (test) ->
    C.Thing = AS.Model.extend()
    C.Thing.property("inverse")
    C.ThingCollection = AS.Collection.extend ->
      @def model: -> C.Thing
      @def inverse: "inverse"

    things = C.ThingCollection.new()
    things.source = "SOURCE"
    thing = things.add()
    things.remove(thing)
    test.equal null, thing.inverse.get()
    test.done()

  "inserts item of specified type": (test) ->
    C.Thing = AS.Model.extend()
    C.ThingCollection = AS.Collection.extend -> @def model: -> C.Thing

    things = C.ThingCollection.new()
    things.add()

    test.ok things.first().value() instanceof C.Thing
    test.done()

  "inserts item at a specified index": (test)->
    things = AS.Collection.new()

    things.add()
    things.add()

    thing = things.add({}, at: 1)

    test.equal things.length, 3
    test.equal things.at(1), thing

    test.done()

  "remove item from collection": (test) ->
    things = AS.Collection.new()
    thing = things.add()
    things.remove(thing)
    test.equal things.length, 0
    test.done()

  Events:
    "add event": (test) ->
      test.expect 1
      collection = AS.Collection.new()
      collection.bind "add", -> test.ok true
      collection.add()
      test.done()

    "remove event": (test) ->
      test.expect 1
      collection = AS.Collection.new()
      thing = collection.add()
      collection.bind "remove", -> test.ok true
      collection.remove(thing)
      test.done()

    "model change events bubble through collection": (test) ->
      test.expect 5
      C.Thing = AS.Model.extend()
      C.Thing.property("name")
      collection = AS.Collection.new()
      thing = collection.add C.Thing.new()
      collection.bind "all", -> test.ok true
      collection.bind "modelevent", -> test.ok true
      collection.bind "change", -> test.ok true
      thing.trigger "modelevent"
      thing.name.set("changed")

      test.done()

    "add/remove events capture on collection": (test) ->
      test.expect 2
      thing = AS.Model.new()
      collection = AS.Collection.new()
      thing.bind "add", -> test.ok true
      thing.bind "remove", -> test.ok true

      collection.add(thing)
      collection.remove(thing)

      test.done()
