{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

exports.Collection =
  "inserts item of specified type": (test) ->
    class Thing extends AS.Model
    class ThingCollection extends AS.Collection
      model: -> Thing

    things = new ThingCollection
    things.add()

    # test.ok things.first().value() instanceof Thing
    test.done()

  "inserts item at a specified index": (test)->
    things = new AS.Collection

    things.add()
    things.add()

    thing = things.add({}, at: 1)

    test.equal things.length, 3
    test.equal things.at(1), thing

    test.done()

  "remove item from collection": (test) ->
    things = new AS.Collection
    thing = things.add()
    things.remove(thing)
    test.equal things.length, 0
    test.done()

  Events:
    "add event": (test) ->
      test.expect 1
      collection = new AS.Collection
      collection.bind "add", -> test.ok true
      collection.add()
      test.done()

    "remove event": (test) ->
      test.expect 1
      collection = new AS.Collection
      thing = collection.add()
      collection.bind "remove", -> test.ok true
      collection.remove(thing)
      test.done()

    "model change events bubble through collection": (test) ->
      test.expect 2
      collection = new AS.Collection
      thing = collection.add()
      collection.bind "all", -> test.ok true
      collection.bind "modelevent", -> test.ok true

      thing.trigger "modelevent"

      test.done()

    "add/remove evends capture on collection": (test) ->
      test.expect 2
      thing = new AS.Model
      collection = new AS.Collection
      thing.bind "add", -> test.ok true
      thing.bind "remove", -> test.ok true

      collection.add(thing)
      collection.remove(thing)

      test.done()
