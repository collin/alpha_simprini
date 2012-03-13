# {AS, _, sinon, coreSetUp, makeDoc} = require require("path").resolve("./test/helper")
# exports.setUp = coreSetUp

# class Shared extends AS.Model
#   AS.Model.Share.extends(this, "Shared")
#   @field "field"
#   @embeds_many "embeds", model: -> SimpleShare
#   @embeds_one "embedded", model: -> SimpleShare
#   @has_many "relations", model: -> SimpleShare
#   @has_one "relation"
#   @belongs_to "owner"

# class SimpleShare extends AS.Model
#   AS.Model.Share.extends(this, "SimpleShare")
#   @field "field"
#   @embeds_many "embeds", model: -> SimplerShare
#   @embeds_one "embedded", model: -> SimplerShare
#   @has_many "relations", model: -> SimplerShare
#   @has_one "relation"
#   @belongs_to "owner"

# class SimplerShare extends AS.Model
#   AS.Model.Share.extends(this, "SimplerShare")
#   @field "field"

# class IndexShare extends AS.Model
#   AS.Model.Share.extends(this, "IndexShare")
#   @index "docs"
#   @belongs_to "owner"

# exports["Model.Share"] =
#   setUp: (callback) ->
#     @real_open = AS.open_shared_object
#     @real_module = AS.module
#     AS.module = (name) ->
#       return {
#         "SimpleShare": SimpleShare,
#         "SimplerShare": SimplerShare,
#         "Shared": Shared,
#         "IndexShare": IndexShare
#       }[name]
#     AS.open_shared_object = (id, did_open) ->
#       did_open makeDoc(id)

#     @remote = (operation, model = @model) ->
#       if model.share.emit
#         model.share.emit "remoteop", operation
#       else
#         model.share.doc.emit "remoteop", operation

#     @model_bindings = (model, test) ->
#       model.field("value")
#       test.equal model.share.at("field").get(), "value", "field model->share"

#       added_relation = SimpleShare.open()
#       model.relations().add added_relation
#       expected_has_many_value = {id: added_relation.id, _type: added_relation.constructor._type}
#       test.deepEqual model.share.at("relations", 0).get(), expected_has_many_value, "has_many model->share"

#       model.embeds().add added_embed = new SimpleShare
#       test.deepEqual model.share.at("embeds", 0).get(), added_embed.attributes_for_sharing(), "embeds_many model->share"

#       model.embeds().remove added_embed
#       test.deepEqual model.share.at("embeds").get(), [], "embeds_many remove->share"

#       model.embedded set_embedded = new SimpleShare
#       test.deepEqual model.share.at("embedded").get(), set_embedded.attributes_for_sharing(), "embeds_one model->share"

#       model.owner set_owner = SimpleShare.open()
#       test.deepEqual model.share.at("owner").get(), set_owner.id, "belongs_to model->share"

#       share = model.share
#       # test share -> attribute

#       @remote share.at("field").insert(0, "!"), model
#       test.equal model.field(), "!value", "field share->model"

#       @remote share.at("field").insert(0, "OBOY "), model
#       test.equal model.field(), "OBOY !value", "field share->model; insert"

#       remote_relation = SimpleShare.open()
#       @remote share.at("relations", model.relations().length).set(remote_relation.attributes_for_sharing()), model
#       test.deepEqual model.relations().last().value().attributes_for_sharing(), remote_relation.attributes_for_sharing(), "has_many share->model"

#       remote_embed = SimpleShare.open()
#       @remote share.at("embeds", model.relations().length).set(remote_embed.attributes_for_sharing()), model
#       test.deepEqual model.embeds().last().value().attributes_for_sharing(), remote_embed.attributes_for_sharing(), "embeds_many share->model"

#       remote_embedded = SimpleShare.open()
#       @remote share.at("embedded").set(remote_embedded.attributes_for_sharing()), model
#       test.deepEqual model.embedded().attributes_for_sharing(), remote_embedded.attributes_for_sharing(), "embeds_one share->model"

#       remote_owner = SimpleShare.open()
#       @remote share.at("owner").set(remote_owner.id), model
#       test.equal model.owner().id, remote_owner.id, "belongs_to share->model"

#     (@model = Shared.open()).when_indexed callback


#   tearDown: (callback) ->
#     AS.open_shared_object = @real_open
#     AS.module = @real_module
#     callback()

#   "Lifecycle State Machine":
#     "share models have a Lifecycle SM": (test) ->
#       test.ok @model.lifecycle instanceof AS.Models.Share.Lifecycle

#     "#open":

#     "#load":
#     "#embedded"



#   "is new if share is undefined": (test) ->
#     delete @model.share
#     test.ok @model.new()
#     test.done()

#   "is new if constructed with new": (test) ->
#     test.ok (new Shared id:"an id").new()
#     test.done()

#   "sets defaults when opening a new model": (test) ->
#     class DefaultShared extends AS.Model
#       AS.Model.Share.extends(this, "DefaultShared")
#       @field "defaulted", default: "value"

#     model = DefaultShared.open("someid")
#     test.equal model.defaulted(), "value"

#     test.done()

#   "overrides defaults when loading remotely": (test) ->
#     AS.open_shared_object = (id, did_open) ->
#       did_open makeDoc(id, defaulted: "REMOTE VALUE")
#     class DefaultShared extends AS.Model
#       AS.Model.Share.extends(this, "DefaultShared")
#       @field "defaulted", default: "value"

#     model = DefaultShared.open("some other id")
#     test.equal model.defaulted(), "REMOTE VALUE"

#     test.done()

#   "sets initial attributes when opening an object": (test) ->
#     test.deepEqual @model.share.get(), @model.attributes_for_sharing()
#     test.done()

#   "updates shared object when model attributes change": (test) ->
#     @model.field("VALUE")
#     test.equal @model.share.at("field").get(), "VALUE"

#     test.done()

#   "adds/removes items to relations in share": (test) ->
#     @model_bindings(@model, test)
#     test.done()

#   "adds items to shared collection at specified index": (test) ->
#     @model.relations().add SimpleShare.open()
#     @model.embeds().add SimpleShare.open()

#     @model.relations().add first_relation = SimpleShare.open(), at: 0
#     @model.embeds().add first_embed = SimpleShare.open(), at: 0

#     relation_attrs =
#       id: first_relation.id
#       _type: first_relation.constructor._type

#     test.deepEqual relation_attrs, @model.share.at("relations", 0).get()
#     test.deepEqual first_embed.attributes_for_sharing(), @model.share.at("embeds", 0).get()

#     test.done()

#   "updates fields when fields change on share": (test) ->
#     test.expect 2
#     @model.bind "change:field", -> test.ok true
#     @remote @model.share.at("field").set("value")
#     test.equal @model.field(), "value"
#     test.done()

#   "updates fields in embeds_one models when change occurs on share": (test) ->
#     test.expect 5

#     @model.embedded first = SimpleShare.open()
#     @model.embedded().bind "change:field", -> test.ok true
#     @remote @model.share.at("embedded", "field").set("value")
#     test.equal first.field(), "value"

#     # make sure when we swap out embeds the only the newer one is changed
#     @model.embedded second = SimpleShare.open()
#     @model.embedded().bind "change:field", -> test.ok true
#     @remote @model.share.at("embedded", "field").set("value2")
#     test.notEqual first.field(), "value2"
#     test.equal second.field(), "value2"

#     test.done()

#   "updates fields on embedded models created in this client": (test)->
#     model = Shared.open()
#     attrs = SimpleShare.open().attributes_for_sharing()
#     attrs.id = "embeddedsharedid"
#     @remote model.share.at("embeds").insert(0, attrs), model

#     test.equal model.embeds().first().value().id, attrs.id

#     embed = model.embeds().first().value()
#     embed.field("!")
#     test.equal embed.share.at("field").get(), "!"

#     @remote embed.share.at("field").insert(0, "BOO"), embed

#     test.equal embed.share.at("field").get(), "BOO!"

#     test.equal embed.field(), "BOO!"

#     test.done()

#   "updates fields on models that have been received over the wire": (test) ->

#     attrs = SimpleShare.open().attributes_for_sharing()
#     attrs.id = "someid"

#     @remote @model.share.at("embeds", 0).set attrs
#     @model_bindings @model.embeds().first().value(), test

#     test.done()

#   "updates belongs_to in has_many models when change occurs on share": (test) ->
#     test.expect 2
#     owner = SimpleShare.open()
#     @model.bind "change:owner", -> test.ok true
#     @remote @model.share.at("owner").set(owner.id)
#     test.equal @model.owner(), owner

#     test.done()

#   "loads models when indexes update": (test) ->
#     (@model = IndexShare.open()).when_indexed =>
#       (other = SimpleShare.open()).when_indexed  =>
#         AS.open_shared_object = (id, did_open) -> did_open other.share
#         @model.bind "indexload", (loaded) =>
#           loaded.when_indexed ->
#             test.done()
#         @remote @model.share.at("index:docs", other.id).set("SimpleShare")

#   "loads models in indexes when opened": (test) ->
#     indexed = new SimpleShare
#     index = {}
#     index[indexed.id] = "SimpleShare"
#     delete AS.All.byId[indexed.id]
#     delete AS.All.byCid[indexed.cid]
#     snap = {}
#     snap["index:docs"] = index
#     snap["owner"] = indexed.id
#     doc = makeDoc(AS.uniq(), snap)

#     @model = new IndexShare

#     AS.open_shared_object = (id, did_open) ->
#       did_open makeDoc(id, indexed.attributes_for_sharing())

#     @model.did_open(doc)
#     @model.when_indexed =>
#       test.notEqual AS.All.byId[indexed.id], undefined
#       test.equal @model.owner(), AS.All.byId[indexed.id]
#       test.done()

#   "removes indexed models from the index when they are destroy()ed": (test) ->
#     indexed = new SimpleShare
#     index = {}
#     index[indexed.id] = "SimpleShare"
#     delete AS.All.byId[indexed.id]
#     delete AS.All.byCid[indexed.cid]
#     snap = {}
#     snap["index:docs"] = index
#     snap["owner"] = indexed.id
#     doc = makeDoc(AS.uniq(), snap)

#     @model = new IndexShare

#     AS.open_shared_object = (id, did_open) ->
#       did_open makeDoc(id, indexed.attributes_for_sharing())

#     test.expect 2
#     @model.did_open(doc)
#     @model.when_indexed =>
#       test.ok @model.index("docs").at(indexed.id).get()
#       indexed.destroy()
#       test.equal @model.index("docs").at(indexed.id).get(), undefined
#       test.done()
