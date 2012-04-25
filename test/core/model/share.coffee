{AS, NS, _, sinon, coreSetUp, makeDoc} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp


NS.Shared = AS.Model.extend ({delegate, include, def, defs}) ->
  @field 'name'
  @field 'number'
  @hasMany 'things', model: -> NS.Shared
  @hasOne 'thing', model: -> NS.Shared
  @belongsTo 'owner', model: (-> NS.Shared), inverse: 'things'

indexedData =
  "NS.Shared":
    "Indexed-1":
      name: "indexed"
      number: 0
      owner: "Shared-4"
      things: "Shared-1"


shareData =
  # index:
  #   "Indexed-1": "NS.Shared"

  "NS.Shared":
    "Shared-1": (
        name: "one", number: "1",
        things: ["Shared-1", "Shared-2"]
        thing: "Shared-3"
        owner: "Shared-4"
      )
    "Shared-2": (name: "two", number: "2", owner: "Shared-1")
    "Shared-3": (name: "three", number: "3", owner: "shared-2")
    "Shared-4": (name: "four", number: "4", things: [])

exports.ShareJSAdapter =
  setUp: (callback) ->
    @model = NS.Shared.find("Shared-1")
    @store = AS.Model.Store.new(adapterClass: AS.Model.ShareJSAdapter)
    @adapter = AS.Model.ShareJSAdapter.new({@model, @store})
    @adapter.didOpen makeDoc(null, shareData)

    callback()

  "loads embedded data": (test) ->
    test.deepEqual(
      @model.things.backingCollection.models.value(),
      [NS.Shared.find("Shared-1"), NS.Shared.find("Shared-2")]
    )

    test.equal @model.thing.get().toString(), NS.Shared.find("Shared-3").toString()
    test.equal @model.owner.get(), NS.Shared.find("Shared-4")

    test.deepEqual ["NS.Shared", "Shared-1", "name"], @model.name.share.path
    test.done()

# Shared = NS.Shared = AS.Model.extend ({delegate, include, def, defs}) ->
#
#   @field "field"
#   @hasMany "relations", model: -> SimpleShare
#   # @hasOne "relation"
#   @belongsTo "owner"

# SimpleShare = NS.SimpleShare = AS.Model.extend ({delegate, include, def, defs}) ->
#
#   @field "field"
#   @hasMany "relations", model: -> SimplerShare
#   # @hasOne "relation"
#   @belongsTo "owner"

# SimplerShare = NS.SimplerShare = AS.Model.extend ({delegate, include, def, defs}) ->
#
#   @field "field"

# IndexShare = NS.IndexShare = AS.Model.extend ({delegate, include, def, defs}) ->
#
#   @index "docs"
#   @belongsTo "owner"

# ORIGINAL_OPEN = AS.openSharedObject

# exports["Model.Share"] =
#   setUp: (callback) ->
#     AS.openSharedObject = (id, didOpen) -> didOpen makeDoc(id)
#     (@model = Shared.shared()).whenIndexed callback

#   tearDown: (callback) ->
#     AS.openSharedObject = ORIGINAL_OPEN
#     callback()

#   "default value is {}": (test) ->
#     test.ok @model.share.get() isnt null
#     test.done()

#   "embedded objects are synced": (test) ->
#      @model.embedded.set(SimpleShare.new())
#      @model.embedded.get().field.set("Hello")
#      test.equal "Hello", @model.share.at("embedded", "field").get()
#      test.done()

#   "embedded lists are synced": (test) ->
#     listenerCount = @model.share._listeners.length
#     embed = @model.embeds.add()
#     embed.field.set(":D")
#     embed.embedded.set(SimpleShare.new())
#     test.equal listenerCount * 3, @model.share._listeners.length
#     @model.embeds.remove(embed)
#     test.equal listenerCount, @model.share._listeners.length
#     embed.field.set("D:")
#     test.deepEqual [], @model.share.at("embeds").get()
#     test.done()

#   "indexes":
#     setUp: (callback) ->
#       (@model = IndexShare.shared()).whenIndexed callback

#     "index is share at correct path": (test) ->
#       test.deepEqual ["index:docs"], @model.index("docs").path
#       test.done()

#     "index is a {} by default": (test) ->
#       test.deepEqual {}, @model.index("docs").get()
#       test.done()

#     "loads models when indexes update": (test) ->
#       (@model = IndexShare.shared()).whenIndexed =>
#         (other = SimpleShare.shared()).whenIndexed  =>
#           AS.openShareObject = (id, didOpen) -> didOpen other.share
#           @model.bind "indexload", (loaded) =>
#             loaded.whenIndexed ->
#               test.done()
#           @model.share.emit(
#             "remoteop",
#             @model.share.at("index:docs", other.id).set(SimpleShare.path())
#           )

#     "loads models in indexes when opened": (test) ->
#       indexed = SimpleShare.new()
#       indexed.owner.set(indexed)
#       index = {}
#       index[indexed.id] = SimpleShare.path()
#       delete AS.All.byId[indexed.id]
#       delete AS.All.byCid[indexed.cid]
#       delete AS.All.byIdRef[indexed.idRef]
#       snap = {}
#       snap["index:docs"] = index
#       snap["owner"] = indexed.id
#       doc = makeDoc(AS.uniq(), snap)
#       @model = IndexShare.new()

#       AS.openSharedObject = (id, didOpen) ->
#         attrs = {owner: indexed.id}
#         didOpen makeDoc(id, attrs)

#       @model.bind "ready", =>
#         test.notEqual AS.All.byId[indexed.id], undefined
#         test.equal @model.owner.get().id, indexed.id
#         test.ok @model.owner.get().share
#         test.equal @model.owner.get(), @model.owner.get().owner.get()
#         test.done()

#       @model.didOpen(doc)

#     "removes indexed models from the index when they are destroy()ed": (test) ->
#       indexed = SimpleShare.new()
#       index = {}
#       index[indexed.id] = SimpleShare.path()
#       delete AS.All.byId[indexed.id]
#       delete AS.All.byCid[indexed.cid]
#       snap = {}
#       snap["index:docs"] = index
#       snap["owner"] = indexed.id
#       doc = makeDoc(AS.uniq(), snap)

#       @model = IndexShare.new()

#       AS.openShareObject = (id, didOpen) ->
#         didOpen makeDoc(id, indexed.attributesForSharing())

#       test.expect 3
#       @model.bind "ready", =>
#         id = indexed.id
#         test.ok @model.index("docs").at(id).get()
#         @model.owner.get().destroy()
#         test.ok not( @model.index("docs").at(id).get() ), "index is cleaned up"
#         test.ok not( @model.owner.get() ), "references are removed"
#         test.done()
#       @model.didOpen(doc)

#   "is new if share is undefined": (test) ->
#     delete @model.share
#     test.ok @model.new()
#     test.done()

#   "is new if constructed with new": (test) ->
#     test.ok Shared.new(id:"an id").new()
#     test.done()

#   "sets defaults when opening a new model": (test) ->
#     NS.DefaultShared = AS.Model.extend ({delegate, include, def, defs}) ->
#
#       @field "defaulted", default: "value"

#     model = NS.DefaultShared.shared("someid")
#     test.equal model.defaulted.get(), "value"

#     test.done()

#   "overrides defaults when loading remotely": (test) ->
#     AS.openSharedObject = (id, didOpen) ->
#       didOpen makeDoc(id, defaulted: "REMOTE VALUE")
#     NS.DefaultShared = AS.Model.extend ({delegate, include, def, defs}) ->
#
#       @field "defaulted", default: "value"

#     model = NS.DefaultShared.shared("some other id")
#     test.equal model.defaulted.get(), "REMOTE VALUE"

#     test.done()

# exports["Share Integration"] =
#   "loads lists of embedded models":
#     setUp: (callback) ->
#       NS.Embed = AS.Model.extend ({delegate, include, def, defs}) ->
#

#         @hasMany 'embeds'

#       callback()

#     "and doesn't double load models loaded from shareJS": (test) ->
#       data = {
#         embeds: [
#           {_type: "NS.Embed", id: "model1"}
#           {_type: "NS.Embed", id: "model2"}
#         ]
#       }

#       share = makeDoc(null, data)

#       o = NS.Embed.new()

#       test.doesNotThrow -> o.didOpen(share)

#       test.equal 2, o.embeds.backingCollection.length

#       test.done()