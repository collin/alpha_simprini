{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

C = AS.Namespace.new("Collections")

C.Model = AS.Model.extend ({delegate, include, def, defs}) ->
  @field "truth", type: Boolean, default: false

C.Collection = AS.Collection.extend ({delegate, include, def, defs}) ->

exports.FilteredCollection =
  "by default, all members are in the filtered collection": (test) ->
    c = C.Collection.new()
    f = c.filter()

    one = c.add C.Model.new()
    two = c.add C.Model.new()
    three = c.add C.Model.new()

    test.deepEqual [one, two, three], f.models.value()
    test.done()

  "removes items from filter when they are removed from collection": (test) ->
    c = C.Collection.new()
    f = c.filter()

    one = c.add C.Model.new()
    two = c.add C.Model.new()
    three = c.add C.Model.new()

    c.remove(two)

    test.deepEqual [one, three], f.models.value()
    test.done()

  "respects filter function when adding models": (test) ->
    c = C.Collection.new()
    f = c.filter (model) -> model.truth.get() is false

    one = c.add C.Model.new()
    two = c.add C.Model.new(truth: true)
    three = c.add C.Model.new()

    test.deepEqual [one, three], f.models.value()
    test.done()

  "add filtered items when they change": (test) ->
    c = C.Collection.new()
    f = c.filter (model) -> model.truth.get() is false

    one = c.add C.Model.new()
    two = c.add C.Model.new(truth: true)
    three = c.add C.Model.new()
    two.truth.set(false)

    test.deepEqual [one, three, two], f.models.value()
    test.done()

  "remove filtered items when they change": (test) ->
    c = C.Collection.new()
    f = c.filter (model) -> model.truth.get() is false

    one = c.add C.Model.new()
    two = c.add C.Model.new()
    three = c.add C.Model.new()

    two.truth.set(true)

    test.deepEqual [one, three], f.models.value()
    test.done()

  "triggers add/remove events": (test) ->
    test.expect 5

    c = C.Collection.new()
    f = c.filter (model) -> model.truth.get() is false

    f.bind "add", (model) -> test.ok(model)
    f.bind "remove", (model) -> test.ok(model)

    one = c.add C.Model.new()
    two = c.add C.Model.new(truth: true)
    three = c.add C.Model.new()

    two.truth.set(false)
    two.truth.set(true)

    test.deepEqual [one, three], f.models.value()
    test.done()

  "re-filters when fn changes": (test) ->
    c = C.Collection.new()
    f = c.filter (model) -> model.truth.get() is false

    one = c.add C.Model.new()
    two = c.add C.Model.new(truth: true)
    three = c.add C.Model.new()

    f.filter.set (model) -> model.truth.get() is true

    test.deepEqual [two], f.models.value()
    test.done()


