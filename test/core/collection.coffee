{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

C = AS.Namespace.create("Collections")

exports.Collection =
  "inserts item of specified type": (test) ->
    C.Thing = AS.Model.extend()
    C.ThingCollection = AS.Collection.extend model: -> C.Thing

    things = C.ThingCollection.create()
    things.add()

    test.ok things.first().value() instanceof C.Thing
    test.done()

  "inserts item at a specified index": (test)->
    things = AS.Collection.create()

    things.add()
    things.add()

    thing = things.add({}, at: 1)

    test.equal things.length, 3
    test.equal things.at(1), thing

    test.done()

  "remove item from collection": (test) ->
    things = AS.Collection.create()
    thing = things.add()
    things.remove(thing)
    test.equal things.length, 0
    test.done()

  Events:
    "add event": (test) ->
      test.expect 1
      collection = AS.Collection.create()
      collection.bind "add", -> test.ok true
      collection.add()
      test.done()

    "remove event": (test) ->
      test.expect 1
      collection = AS.Collection.create()
      thing = collection.add()
      collection.bind "remove", -> test.ok true
      collection.remove(thing)
      test.done()

    "model change events bubble through collection": (test) ->
      test.expect 2
      collection = AS.Collection.create()
      thing = collection.add()
      collection.bind "all", -> test.ok true
      collection.bind "modelevent", -> test.ok true

      thing.trigger "modelevent"

      test.done()

    "add/remove events capture on collection": (test) ->
      test.expect 2
      thing = AS.Model.create()
      collection = AS.Collection.create()
      thing.bind "add", -> test.ok true
      thing.bind "remove", -> test.ok true

      collection.add(thing)
      collection.remove(thing)

      test.done()
