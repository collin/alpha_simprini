C = AS.Namespace.new("Collections")

module "Collection"
test "sets the inverse is specified", ->
  C.Thing = AS.Model.extend()
  C.Thing.property("inverse")
  C.Thing.property("name")
  C.ThingCollection = AS.Collection.extend ->
    @def model: -> C.Thing
    @def inverse: "inverse"

  things = C.ThingCollection.new()
  things.source = "SOURCE"
  things.add()

  equal "SOURCE", things.first().value().inverse.get()

test "clears inverse if specified", ->
  C.Thing = AS.Model.extend()
  C.Thing.property("inverse")
  C.ThingCollection = AS.Collection.extend ->
    @def model: -> C.Thing
    @def inverse: "inverse"

  things = C.ThingCollection.new()
  things.source = "SOURCE"
  thing = things.add()
  things.remove(thing)
  equal null, thing.inverse.get()

test "inserts item of specified type", ->
  C.Thing = AS.Model.extend()
  C.ThingCollection = AS.Collection.extend -> @def model: -> C.Thing

  things = C.ThingCollection.new()
  things.add()

  ok things.first().value() instanceof C.Thing

test "inserts item at a specified index",->
  things = AS.Collection.new()

  things.add()
  things.add()

  thing = things.add({}, at: 1)

  equal things.length, 3
  equal things.at(1), thing


test "remove item from collection", ->
  things = AS.Collection.new()
  thing = things.add()
  things.remove(thing)
  equal things.length, 0

module "Events"
test "add event", ->
  expect 1
  collection = AS.Collection.new()
  collection.bind "add", -> ok true
  collection.add()
  Taxi.Governer.exit()

test "remove event", ->
  expect 1
  collection = AS.Collection.new()
  thing = collection.add()
  collection.bind "remove", -> ok true
  collection.remove(thing)
  Taxi.Governer.exit()

test "model change events bubble through collection", ->
  expect 1
  C.Thing = AS.Model.extend()
  C.Thing.property("name")
  collection = AS.Collection.new()
  thing = collection.add C.Thing.new()
  # collection.bind "all", -> ok true
  # collection.bind "modelevent", -> ok true
  collection.bind "change", -> ok true
  # thing.trigger "modelevent"
  thing.name.set("changed")
  Taxi.Governer.exit()



test "add events capture on collection", ->
  expect 1
  thing = AS.Model.new()
  collection = AS.Collection.new()
  thing.bind "add", -> ok true

  collection.add(thing)
  Taxi.Governer.exit()
  
test "remove events capture on collection", ->
  expect 1
  thing = AS.Model.new()
  collection = AS.Collection.new()
  thing.bind "remove", -> ok true

  collection.add(thing)
  collection.remove(thing)
  Taxi.Governer.exit()
  