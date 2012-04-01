{AS, NS, _, sinon, coreSetUp, makeDoc} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

Shared = NS.Shared = AS.Model.extend ({delegate, include, def, defs}) ->
  include AS.Model.Share
  @field "field"
  @embedsMany "embeds", model: -> SimpleShare
  @embedsOne "embedded", model: -> SimpleShare
  @hasMany "relations", model: -> SimpleShare
  # @hasOne "relation"
  @belongsTo "owner"

SimpleShare = NS.SimpleShare = AS.Model.extend ({delegate, include, def, defs}) ->
  include AS.Model.Share
  @field "field"
  @embedsMany "embeds", model: -> SimplerShare
  @embedsOne "embedded", model: -> SimplerShare
  @hasMany "relations", model: -> SimplerShare
  # @hasOne "relation"
  @belongsTo "owner"

SimplerShare = NS.SimplerShare = AS.Model.extend ({delegate, include, def, defs}) ->
  include AS.Model.Share
  @field "field"

IndexShare = NS.IndexShare = AS.Model.extend ({delegate, include, def, defs}) ->
  include AS.Model.Share
  @index "docs"
  @belongsTo "owner"

ORIGINAL_OPEN = AS.openSharedObject

exports["Model.Share"] =
  setUp: (callback) ->
    AS.openSharedObject = (id, didOpen) -> didOpen makeDoc(id)
    (@model = Shared.shared()).whenIndexed callback

  tearDown: (callback) ->
    AS.openSharedObject = ORIGINAL_OPEN
    callback()

  "default value is {}": (test) ->
    test.ok @model.share.get() isnt null
    test.done()

  "embedded objects are synced": (test) ->
     @model.embedded.set(SimpleShare.new())
     @model.embedded.get().field.set("Hello")
     test.equal "Hello", @model.share.at("embedded", "field").get()
     test.done()

  "embedded lists are synced": (test) ->
    listenerCount = @model.share._listeners.length
    embed = @model.embeds.add()
    embed.field.set(":D")
    embed.embedded.set(SimpleShare.new())
    test.equal listenerCount * 3, @model.share._listeners.length
    @model.embeds.remove(embed)
    test.equal listenerCount, @model.share._listeners.length
    embed.field.set("D:")
    test.deepEqual [], @model.share.at("embeds").get()
    test.done()

  "indexes": 
    setUp: (callback) ->
      (@model = IndexShare.shared()).whenIndexed callback

    "index is share at correct path": (test) ->
      test.deepEqual ["index:docs"], @model.index("docs").path
      test.done()

    "index is a {} by default": (test) ->
      test.deepEqual {}, @model.index("docs").get()
      test.done()

    "loads models when indexes update": (test) ->
      (@model = IndexShare.shared()).whenIndexed =>
        (other = SimpleShare.shared()).whenIndexed  =>
          AS.openShareObject = (id, didOpen) -> didOpen other.share
          @model.bind "indexload", (loaded) =>
            loaded.whenIndexed ->
              test.done()
          @model.share.emit(
            "remoteop", 
            @model.share.at("index:docs", other.id).set(SimpleShare.path())
          )
          
    "loads models in indexes when opened": (test) ->
      indexed = SimpleShare.new()
      index = {}
      index[indexed.id] = SimpleShare.path()
      delete AS.All.byId[indexed.id]
      delete AS.All.byCid[indexed.cid]
      snap = {}
      snap["index:docs"] = index
      snap["owner"] = indexed.id
      doc = makeDoc(AS.uniq(), snap)
      @model = IndexShare.new()

      AS.openShareObject = (id, didOpen) ->
        didOpen makeDoc(id, indexed.attributesForSharing())

      @model.didOpen(doc)
      @model.whenIndexed =>
        test.notEqual AS.All.byId[indexed.id], undefined
        test.equal @model.owner.get().id, indexed.id
        test.done()

    "removes indexed models from the index when they are destroy()ed": (test) ->
      indexed = SimpleShare.new()
      index = {}
      index[indexed.id] = SimpleShare.path()
      delete AS.All.byId[indexed.id]
      delete AS.All.byCid[indexed.cid]
      snap = {}
      snap["index:docs"] = index
      snap["owner"] = indexed.id
      doc = makeDoc(AS.uniq(), snap)

      @model = IndexShare.new()

      AS.openShareObject = (id, didOpen) ->
        didOpen makeDoc(id, indexed.attributesForSharing())

      test.expect 3
      @model.didOpen(doc)
      @model.whenIndexed =>
        id = indexed.id
        test.ok @model.index("docs").at(id).get()
        @model.owner.get().destroy()
        test.equal undefined, @model.index("docs").at(id).get()
        test.equal undefined, @model.owner.get()
        test.done()

  "is new if share is undefined": (test) ->
    delete @model.share
    test.ok @model.new()
    test.done()

  "is new if constructed with new": (test) ->
    test.ok Shared.new(id:"an id").new()
    test.done()

  "sets defaults when opening a new model": (test) ->
    NS.DefaultShared = AS.Model.extend ({delegate, include, def, defs}) ->
      include AS.Model.Share
      @field "defaulted", default: "value"

    model = NS.DefaultShared.shared("someid")
    test.equal model.defaulted.get(), "value"

    test.done()

  "overrides defaults when loading remotely": (test) ->
    AS.openSharedObject = (id, didOpen) ->
      didOpen makeDoc(id, defaulted: "REMOTE VALUE")
    NS.DefaultShared = AS.Model.extend ({delegate, include, def, defs}) ->
      include AS.Model.Share
      @field "defaulted", default: "value"

    model = NS.DefaultShared.shared("some other id")
    test.equal model.defaulted.get(), "REMOTE VALUE"

    test.done()
