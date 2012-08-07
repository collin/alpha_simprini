C = AS.Namespace.new("Collections")

C.Model = AS.Model.extend ({delegate, include, def, defs}) ->
  @field "truth", type: AS.Model.Boolean, default: false

C.Collection = AS.Collection.extend ({delegate, include, def, defs}) ->

module "FilteredCollection"
test "by default, all members are in the filtered collection", ->
  c = C.Collection.new()
  f = c.filter()

  one = c.add C.Model.new()
  two = c.add C.Model.new()
  three = c.add C.Model.new()
  Taxi.Governer.exit()
  deepEqual f.models.value(), [one, two, three]
test "removes items from filter when they are removed from collection", ->
  c = C.Collection.new()
  f = c.filter()

  one = c.add C.Model.new()
  two = c.add C.Model.new()
  three = c.add C.Model.new()

  c.remove(two)

  Taxi.Governer.exit()
  deepEqual f.models.value(), [one, three]

test "respects filter function when adding models", ->
  c = C.Collection.new()
  f = c.filter truth: false

  one = c.add C.Model.new()
  two = c.add C.Model.new(truth: true)
  three = c.add C.Model.new()

  Taxi.Governer.exit()
  deepEqual f.models.value(), [one, three]

test "add filtered items when they change", ->
  c = C.Collection.new()
  f = c.filter truth: false

  one = c.add C.Model.new()
  two = c.add C.Model.new(truth: true)
  three = c.add C.Model.new()
  two.truth.set(false)

  Taxi.Governer.exit()
  deepEqual f.models.pluck('id').sort().value(), _([one, three, two]).pluck("id").sort()

test "remove filtered items when they change", ->
  c = C.Collection.new()
  f = c.filter truth: false

  one = c.add C.Model.new()
  two = c.add C.Model.new()
  three = c.add C.Model.new()

  two.truth.set(true)

  Taxi.Governer.exit()
  deepEqual f.models.value(), [one, three]

test "triggers add/remove events", ->
  expect 5

  c = C.Collection.new()
  f = c.filter truth: false

  f.bind "add", -> ok true
  f.bind "remove", -> ok true

  one = c.add C.Model.new()
  Taxi.Governer.exit()

  two = c.add C.Model.new(truth: true)
  Taxi.Governer.exit()

  three = c.add C.Model.new()
  Taxi.Governer.exit()

  two.truth.set(false)
  Taxi.Governer.exit()

  two.truth.set(true)
  Taxi.Governer.exit()

  deepEqual f.models.pluck('id').value(), [one.id, three.id]

test "re-filters when filter changes", ->
  c = C.Collection.new()
  f = c.filter truth: false

  one = c.add C.Model.new()
  two = c.add C.Model.new(truth: true)
  three = c.add C.Model.new()

  f.setConditions(truth: true)

  Taxi.Governer.exit()
  deepEqual f.models.value(), [two]



