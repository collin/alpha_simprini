{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

C = AS.Namespace.new("Collections")

C.Model = AS.Model.extend ({delegate, include, def, defs}) ->
  @field "truth", type: Boolean, default: false

C.Collection = AS.Collection.extend ({delegate, include, def, defs}) ->

module "FilteredCollection"
test "by default, all members are in the filtered collection", ->
  c = C.Collection.new()
  f = c.filter()

  one = c.add C.Model.new()
  two = c.add C.Model.new()
  three = c.add C.Model.new()

  deepEqual [one, two, three], f.models.value()
  
test "removes items from filter when they are removed from collection", ->
  c = C.Collection.new()
  f = c.filter()

  one = c.add C.Model.new()
  two = c.add C.Model.new()
  three = c.add C.Model.new()

  c.remove(two)

  deepEqual [one, three], f.models.value()
  
test "respects filter function when adding models", ->
  c = C.Collection.new()
  f = c.filter truth: false

  one = c.add C.Model.new()
  two = c.add C.Model.new(truth: true)
  three = c.add C.Model.new()

  deepEqual [one, three], f.models.value()
  
test "add filtered items when they change", ->
  c = C.Collection.new()
  f = c.filter truth: false

  one = c.add C.Model.new()
  two = c.add C.Model.new(truth: true)
  three = c.add C.Model.new()
  two.truth.set(false)

  deepEqual [one, three, two], f.models.value()
  
test "remove filtered items when they change", ->
  c = C.Collection.new()
  f = c.filter truth: false

  one = c.add C.Model.new()
  two = c.add C.Model.new()
  three = c.add C.Model.new()

  two.truth.set(true)

  deepEqual [one, three], f.models.value()
  
test "triggers add/remove events", ->
  expect 5

  c = C.Collection.new()
  f = c.filter truth: false

  f.bind "add", (model) -> ok(model)
  f.bind "remove", (model) -> ok(model)

  one = c.add C.Model.new()
  two = c.add C.Model.new(truth: true)
  three = c.add C.Model.new()

  two.truth.set(false)
  two.truth.set(true)

  deepEqual [one, three], f.models.value()
  
test "re-filters when filter changes", ->
  c = C.Collection.new()
  f = c.filter truth: false

  one = c.add C.Model.new()
  two = c.add C.Model.new(truth: true)
  three = c.add C.Model.new()

  f.setConditions(truth: true)

  deepEqual [two], f.models.value()
  


