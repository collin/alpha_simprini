{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

G = AS.Namespace.new("Grouping")

G.Model = AS.Model.extend ({delegate, include, def, defs}) ->
  @field "point", default: "default"

G.Collection = AS.Collection.extend ({delegate, include, def, defs}) ->
  model: -> G.Model

exports["Models.Grouping"] =
  setUp: (callback) ->
    @c = G.Collection.new()
    @g = @c.groupBy("point")
    callback()

  "adds item to a group": (test) ->
    @c.add G.Model.new()
    @c.add G.Model.new()

    test.equal 2, @g.groupMap.get("default").membersCount.get()

    test.done()

  "removes items from their gorup": (test) ->
    @c.add G.Model.new()
    item = @c.add G.Model.new()
    @c.remove(item)

    test.equal 1, @g.groupMap.get("default").membersCount.get()

    test.done()

  "moves items inbetween groups": (test) ->
    @c.add G.Model.new()
    item = @c.add G.Model.new()
    item.point.set("alternate")

    test.equal 1, @g.groupMap.get("default").membersCount.get()
    test.equal 1, @g.groupMap.get("alternate").membersCount.get()

    test.done()
