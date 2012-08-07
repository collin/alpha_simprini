module "utilities"
test "testIdentity", ->
  ok AS.Identity(10)(10)

test "constructorIdentity", ->
  class Fake
  ok AS.ConstructorIdentity(Fake)(new Fake)

test "deepClone", ->
  notEqual AS.deepClone(it = []), it
  notEqual AS.deepClone(it = {}), it

  deepEqual AS.deepClone(it = []), it
  deepEqual AS.deepClone(it = {}), it

  it = [
    {a: 134, 3: [2, {}, [], [], "FOO"]},
    23, "BAR"
  ]
  deepEqual AS.deepClone(it), it
  not_it = AS.deepClone(it)
  not_it.push "BAZ"
  notDeepEqual it, not_it

test "uniq", ->
  ok AS.uniq().match /^\w+$/
  notEqual AS.uniq(), AS.uniq()

test "humanSize", ->
  sz = AS.humanSize

  equal sz(100), "100.0 B"

  for prefix, index in ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
    equal sz(Math.pow(1024, index + 1)), "1.0 #{prefix}"
