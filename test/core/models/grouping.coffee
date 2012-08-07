G = AS.Namespace.new("Grouping")

G.Model = AS.Model.extend ({delegate, include, def, defs}) ->
  @field "point", default: "default"

G.Collection = AS.Collection.extend ({delegate, include, def, defs}) ->
  model: -> G.Model

module "Models.Grouping",
  setup: ->
    @c = G.Collection.new()
    @g = @c.groupBy("point")

test "adds item to a group", ->
  @c.add G.Model.new()
  @c.add G.Model.new()

  Taxi.Governer.exit()

  equal 2, @g.groupMap.get("default").membersCount.get()


test "removes items from their gorup", ->
  @c.add G.Model.new()
  item = @c.add G.Model.new()
  @c.remove(item)
  Taxi.Governer.exit()
  equal 1, @g.groupMap.get("default").membersCount.get()


test "moves items inbetween groups", ->
  @c.add G.Model.new()
  item = @c.add G.Model.new()
  item.point.set("alternate")

  Taxi.Governer.exit()

  equal 1, @g.groupMap.get("default").membersCount.get()
  equal 1, @g.groupMap.get("alternate").membersCount.get()

  