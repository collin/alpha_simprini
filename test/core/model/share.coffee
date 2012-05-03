Shared = Pathology.Namespace.new("Shared")

Shared.Shared = AS.Model.extend ({delegate, include, def, defs}) ->
  @field 'name'
  @field 'number'
  @hasMany 'things', model: -> Shared.Shared
  @hasOne 'thing', model: -> Shared.Shared
  @belongsTo 'owner', model: (-> Shared.Shared), inverse: 'things'

indexedData =
  "Shared.Shared":
    "Indexed-1":
      name: "indexed"
      number: 0
      owner: "Shared-4"
      things: "Shared-1"

makeDoc = NS.makeDoc

shareData =
  # index:
  #   "Indexed-1": "Shared.Shared"

  "Shared.Shared":
    "Shared-1": (
        name: "one", number: "1",
        things: ["Shared-1", "Shared-2"]
        thing: "Shared-3"
        owner: "Shared-4"
      )
    "Shared-2": (name: "two", number: "2", owner: "Shared-1")
    "Shared-3": (name: "three", number: "3", owner: "shared-2")
    "Shared-4": (name: "four", number: "4", things: [])

module "ShareJSAdapter",
  setup: ->
    @model = Shared.Shared.find("Shared-1")
    @store = AS.Model.Store.new(adapterClass: AS.Model.ShareJSAdapter)
    @adapter = AS.Model.ShareJSAdapter.new({@model, @store})
    @adapter.didOpen makeDoc(null, shareData)

test "loads embedded data", ->
    deepEqual(
      @model.things.backingCollection.models.value(),
      [Shared.Shared.find("Shared-1"), Shared.Shared.find("Shared-2")]
    )

    equal @model.thing.get(), Shared.Shared.find("Shared-3")
    equal @model.owner.get(), Shared.Shared.find("Shared-4")

    deepEqual ["Shared.Shared", "Shared-1", "name"], @model.name.share.path

# Shared = Shared.Shared = AS.Model.extend ({delegate, include, def, defs}) ->
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

#   "default value is {}", ->
#     ok @model.share.get() isnt null
#
#   "embedded objects are synced", ->
#      @model.embedded.set(SimpleShare.new())
#      @model.embedded.get().field.set("Hello")
#      equal "Hello", @model.share.at("embedded", "field").get()
#
#   "embedded lists are synced", ->
#     listenerCount = @model.share._listeners.length
#     embed = @model.embeds.add()
#     embed.field.set(":D")
#     embed.embedded.set(SimpleShare.new())
#     equal listenerCount * 3, @model.share._listeners.length
#     @model.embeds.remove(embed)
#     equal listenerCount, @model.share._listeners.length
#     embed.field.set("D:")
#     deepEqual [], @model.share.at("embeds").get()
#
#   "indexes":
#     setUp: (callback) ->
#       (@model = IndexShare.shared()).whenIndexed callback

#     "index is share at correct path", ->
#       deepEqual ["index:docs"], @model.index("docs").path
#
#     "index is a {} by default", ->
#       deepEqual {}, @model.index("docs").get()
#
#     "loads models when indexes update", ->
#       (@model = IndexShare.shared()).whenIndexed =>
#         (other = SimpleShare.shared()).whenIndexed  =>
#           AS.openShareObject = (id, didOpen) -> didOpen other.share
#           @model.bind "indexload", (loaded) =>
#             loaded.whenIndexed ->
#               #           @model.share.emit(
#             "remoteop",
#             @model.share.at("index:docs", other.id).set(SimpleShare.path())
#           )

#     "loads models in indexes when opened", ->
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
#         notEqual AS.All.byId[indexed.id], undefined
#         equal @model.owner.get().id, indexed.id
#         ok @model.owner.get().share
#         equal @model.owner.get(), @model.owner.get().owner.get()
#
#       @model.didOpen(doc)

#     "removes indexed models from the index when they are destroy()ed", ->
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

#       expect 3
#       @model.bind "ready", =>
#         id = indexed.id
#         ok @model.index("docs").at(id).get()
#         @model.owner.get().destroy()
#         ok not( @model.index("docs").at(id).get() ), "index is cleaned up"
#         ok not( @model.owner.get() ), "references are removed"
#         #       @model.didOpen(doc)

#   "is new if share is undefined", ->
#     delete @model.share
#     ok @model.new()
#
#   "is new if constructed with new", ->
#     ok Shared.new(id:"an id").new()
#
#   "sets defaults when opening a new model", ->
#     NS.DefaultShared = AS.Model.extend ({delegate, include, def, defs}) ->
#
#       @field "defaulted", default: "value"

#     model = NS.DefaultShared.shared("someid")
#     equal model.defaulted.get(), "value"

#
#   "overrides defaults when loading remotely", ->
#     AS.openSharedObject = (id, didOpen) ->
#       didOpen makeDoc(id, defaulted: "REMOTE VALUE")
#     NS.DefaultShared = AS.Model.extend ({delegate, include, def, defs}) ->
#
#       @field "defaulted", default: "value"

#     model = NS.DefaultShared.shared("some other id")
#     equal model.defaulted.get(), "REMOTE VALUE"

#
# exports["Share Integration"] =
#   "loads lists of embedded models":
#     setUp: (callback) ->
#       NS.Embed = AS.Model.extend ({delegate, include, def, defs}) ->
#

#         @hasMany 'embeds'

#       callback()

#     "and doesn't double load models loaded from shareJS", ->
#       data = {
#         embeds: [
#           {_type: "NS.Embed", id: "model1"}
#           {_type: "NS.Embed", id: "model2"}
#         ]
#       }

#       share = makeDoc(null, data)

#       o = NS.Embed.new()

#       doesNotThrow -> o.didOpen(share)

#       equal 2, o.embeds.backingCollection.length

#       