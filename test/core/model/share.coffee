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


# exports["Model.Share"] =
#   setUp: (callback) ->
#     @real_open = AS.openSharedObject

#     AS.openSharedObject = (id, didOpen) ->
#       didOpen makeDoc(id)

#     @remote = (operation, model = @model) ->
#       if model.share.emit
#         model.share.emit "remoteop", operation
#       else
#         model.share.doc.emit "remoteop", operation

#     @model_bindings = (model, test) ->
#       model.field.set("value")
#       test.equal model.share.at("field").get(), "value", "field model->share"

#       added_relation = SimpleShare.shared()
#       model.relations.add added_relation
#       expected_has_many_value = {id: added_relation.id, _type: added_relation.constructor._type}
#       test.deepEqual model.share.at("relations", 0).get(), expected_has_many_value, "has_many model->share"

#       # model.embeds().add added_embed = SimpleShare.new()
#       # test.deepEqual model.share.at("embeds", 0).get(), added_embed.attributesForSharing(), "embeds_many model->share"

#       # model.embeds().remove added_embed
#       # test.deepEqual model.share.at("embeds").get(), [], "embeds_many remove->share"

#       # model.embedded set_embedded = SimpleShare.new()
#       # test.deepEqual model.share.at("embedded").get(), set_embedded.attributesForSharing(), "embeds_one model->share"

#       # model.owner set_owner = SimpleShare.shared()
#       # test.deepEqual model.share.at("owner").get(), set_owner.id, "belongsTo model->share"

#       # share = model.share

#       # @remote share.at("field").insert(0, "!"), model
#       # test.equal model.field(), "!value", "field share->model"

#       # @remote share.at("field").insert(0, "OBOY "), model
#       # test.equal model.field(), "OBOY !value", "field share->model; insert"

#       # remote_relation = SimpleShare.shared()
#       # @remote share.at("relations", model.relations().length).set(remote_relation.attributesForSharing()), model
#       # test.deepEqual model.relations().last().value().attributesForSharing(), remote_relation.attributesForSharing(), "has_many share->model"

#       # remote_embed = SimpleShare.shared()
#       # @remote share.at("embeds", model.relations().length).set(remote_embed.attributesForSharing()), model
#       # test.deepEqual model.embeds().last().value().attributesForSharing(), remote_embed.attributesForSharing(), "embeds_many share->model"

#       # remote_embedded = SimpleShare.shared()
#       # @remote share.at("embedded").set(remote_embedded.attributesForSharing()), model
#       # test.deepEqual model.embedded().attributesForSharing(), remote_embedded.attributesForSharing(), "embeds_one share->model"

#       # remote_owner = SimpleShare.shared()
#       # @remote share.at("owner").set(remote_owner.id), model
#       # test.equal model.owner().id, remote_owner.id, "belongsTo share->model"


#     (@model = Shared.shared()).whenIndexed callback

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

  # "sets initial attributes when opening an object": (test) ->
  #   test.deepEqual @model.share.get(), @model.attributesForSharing()
  #   test.done()

  # "updates shared object when model attributes change": (test) ->
  #   @model.field.set("VALUE")
  #   test.equal @model.share.at("field").get(), "VALUE"

  #   test.done()

  # "adds/removes items to relations in share": (test) ->
  #   @model_bindings(@model, test)
  #   test.done()

  # "adds items to shared collection at specified index": (test) ->
  #   @model.relations().add SimpleShare.shared()
  #   @model.embeds().add SimpleShare.shared()

  #   @model.relations().add first_relation = SimpleShare.shared(), at: 0
  #   @model.embeds().add first_embed = SimpleShare.shared(), at: 0

  #   relation_attrs =
  #     id: first_relation.id
  #     _type: first_relation.constructor._type

  #   test.deepEqual relation_attrs, @model.share.at("relations", 0).get()
  #   test.deepEqual first_embed.attributesForSharing(), @model.share.at("embeds", 0).get()

  #   test.done()

  # "updates fields in embeds_one models when change occurs on share": (test) ->
  #   test.expect 5

  #   @model.embedded first = SimpleShare.shared()
  #   @model.embedded().bind "change:field", -> test.ok true
  #   @remote @model.share.at("embedded", "field").set("value")
  #   test.equal first.field(), "value"

  #   # make sure when we swap out embeds the only the newer one is changed
  #   @model.embedded second = SimpleShare.shared()
  #   @model.embedded().bind "change:field", -> test.ok true
  #   @remote @model.share.at("embedded", "field").set("value2")
  #   test.notEqual first.field(), "value2"
  #   test.equal second.field(), "value2"

  #   test.done()

  # "updates fields on embedded models created in this client": (test)->
  #   model = Shared.shared()
  #   attrs = SimpleShare.shared().attributesForSharing()
  #   attrs.id = "embeddedsharedid"
  #   @remote model.share.at("embeds").insert(0, attrs), model

  #   test.equal model.embeds().first().value().id, attrs.id

  #   embed = model.embeds().first().value()
  #   embed.field("!")
  #   test.equal embed.share.at("field").get(), "!"

  #   @remote embed.share.at("field").insert(0, "BOO"), embed

  #   test.equal embed.share.at("field").get(), "BOO!"

  #   test.equal embed.field(), "BOO!"

  #   test.done()

  # "updates fields on models that have been received over the wire": (test) ->

  #   attrs = SimpleShare.shared().attributesForSharing()
  #   attrs.id = "someid"

  #   @remote @model.share.at("embeds", 0).set attrs
  #   @model_bindings @model.embeds.first().value.get(), test

  #   test.done()

  # "updates belongsTo in has_many models when change occurs on share": (test) ->
  #   test.expect 2
  #   owner = SimpleShare.shared()
  #   @model.bind "change:owner", -> test.ok true
  #   @remote @model.share.at("owner").set(owner.id)
  #   test.equal @model.owner.get(), owner

  #   test.done()

