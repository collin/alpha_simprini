{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

exports.Model =
  "has a place for all models": (test) ->
    test.deepEqual AS.All, byCid: {}, byId: {}
    test.done()

  "puts new models in that place": (test) ->
    model = new AS.Model
    test.equal AS.All.byCid[model.cid], model
    test.equal AS.All.byId[model.id], model
    test.done()

  "runs initialize callbacks": (test) ->
    test.expect 2
    class AModel extends AS.Model
      @before_initialize -> test.ok true
      @after_initialize -> test.ok true
    new AModel
    test.done()

  "calls initialize method when constructed": (test) ->
    class AModel extends AS.Model
      initialize: ->
        super
        @initialized = true

    test.ok (new AModel).initialized
    test.done()

  "is a new record if has no id in attributes": (test) ->
    model = new AS.Model
    delete model.attributes.id
    test.ok model.new()
    test.done()

  virtual_properties:
    "reflection": (test) ->
      class Virtuals extends AS.Model
        @field "fieldname"
        @virtual_properties "fieldname",
          one: ->
          two: ->

      test.deepEqual Virtuals.virtuals,
        one: ["fieldname"]
        two: ["fieldname"]

      test.done()

    "virtual properties trigger change events when pointed to fields": (test) ->
      test.expect 3

      class Virtuals extends AS.Model
        @field "firstname"
        @field "lastname"
        @virtual_properties "firstname", "lastname",
          fullname: -> "#{@firstname()} #{@lastname()}"

      model = new Virtuals firstname: "Collin", lastname: "Miller"

      test.equal "Collin Miller", model.fullname()
      model.bind "change:fullname", (name, value, options) -> test.ok true

      model.firstname "First"
      model.lastname "Last"

      test.done()

    "virtual properties trigger change events when pointed to has_manys": (test) ->
      test.expect 3

      class Countable extends AS.Model
        @has_many "things", model: -> AS.Model

        @virtual_properties "things",
          things_count: -> @things().length

      model = new Countable
      things  = model.things()
      things.add()
      things.add()
      things.add()

      test.equal 3, model.things_count()

      model.bind "change:things_count", -> test.ok true

      last = things.add()
      things.remove last

      test.done()

    "virtual properties trigger change events when pointed to embeds": (test) ->
      test.expect 3

      class Countable extends AS.Model
        @embeds_many "things", model: -> AS.Model

        @virtual_properties "things",
          things_count: -> @things().length

      model = new Countable
      things  = model.things()
      things.add()
      things.add()
      things.add()

      test.equal 3, model.things_count()

      model.bind "change:things_count", -> test.ok true

      last = things.add()
      things.remove last

      test.done()

    "virtual properties don't trigger if the value hasn't changed": (test) ->
      test.expect 1

      class Countable extends AS.Model
        @embeds_many "things", model: -> AS.Model

        @virtual_properties "things",
          things_count: -> "NEVER CHANGES"

      model = new Countable
      things  = model.things()
      things.add()
      things.add()
      things.add()

      test.equal "NEVER CHANGES", model.things_count()

      model.bind "change:things_count", -> test.ok true

      last = things.add()
      things.remove last

      test.done()

  field:
    reflection: (test) ->
      test.ok FieldModel.fields.name
      test.done()

    getting: (test) ->
      test.equal (new FieldModel name: "aname").name(), "aname"
      test.done()

    setting: (test) ->
      m = new FieldModel
      m.name("name")
      test.equal m.name(), "name"
      test.done()

    lastValue: (test) ->
      m = new FieldModel
      m.name "first"
      m.save()
      m.name "second"
      test.equal m.last("name"), "first"
      test.done()

    listening: (test) ->
      test.expect 2
      m = new FieldModel
      m.bind "change:name", -> test.ok true
      m.bind "change", -> test.ok true
      m.name "gogogo"
      test.done()

    "sets default field values": (test) ->
      class DefaultModel extends AS.Model
        @field "defaulted", default: "CRAZY AWESOME"

      test.equal (new DefaultModel).defaulted(), "CRAZY AWESOME"

      test.done()

    "but not when the record already exists": (test) ->
      class DefaultModel extends AS.Model
        @field "defaulted", default: "CRAZY AWESOME"

      test.notEqual (new DefaultModel id:"exists").defaulted(), "CRAZY AWESOME"

      test.done()

    types:
      Boolean: (test) ->
        class BooleanModel extends AS.Model
          @field "field", type: Boolean

        model = new BooleanModel

        model.field true

        test.equals model.field(), true

        model.field "false"
        test.equals model.field(), false

        test.done()

      # STUBS
      # String:
      # Number:

  relation:
    # "requires model configurations": (test) ->
    #   test.throws -> RelationModel.embeds_one "misconfigured"
    reflection: (test) ->
      test.deepEqual RelationModel.relations, relations =  [ 'embeds', 'embed', 'relations', 'relation', 'owner' ]

      test.deepEqual RelationModel.embeds_manys, embeds: relation: true
      test.deepEqual RelationModel.embeds_ones, embed: relation: true
      test.deepEqual RelationModel.has_manys, relations: relation: true
      test.deepEqual RelationModel.has_ones, relation: relation: true
      test.deepEqual RelationModel.belongs_tos, owner: relation: true

      test.done()

    "gets and sets belongs to association": (test) ->
      model = new RelationModel
      owned = new FieldModel
      model.owner owned
      test.equal model.owner(), owned
      test.done()

    "gets and sets embeds one association": (test) ->
      model = new RelationModel
      embedded = new FieldModel
      model.embed embedded
      test.equal model.embed(), embedded
      test.done()

    "gets and sets has one association": (test) ->
      model = new RelationModel
      related = new FieldModel
      model.relation related
      test.equal model.relation(), related
      test.done()

    "has many association is a collection": (test) ->
      model = new RelationModel
      relations = model.relations()
      test.ok relations instanceof AS.Collection
      test.done()

    "embeds many association is a collection": (test) ->
      model = new RelationModel
      embeds = model.embeds()
      test.ok embeds instanceof AS.EmbeddedCollection
      test.done()

    "has many configuration passes through" : (test) ->
      things_config =
        model: -> "RETURNS A MODEL IN REALITY"

      class AModel extends AS.Model

        @has_many "things", things_config

      test.equal (new AModel).things().model, things_config.model
      test.done()

    "sets source on has many relation": (test) ->
      model = new RelationModel
      test.equal model.relations().source, model
      test.done()

    "has many configuration passes through" : (test) ->
      things_config =
        model: -> "RETURNS A MODEL IN REALITY"

      class AModel extends AS.Model

        @embeds_many "things", things_config

      test.equal (new AModel).things().model, things_config.model
      test.done()

    "sets source on embeds many relation": (test) ->
      model = new RelationModel
      test.equal model.embeds().source, model
      test.done()

    "destroy triggers destroy event": (test) ->
      test.expect 1
      model = new AS.Model
      model.bind "destroy", -> test.ok true
      model.destroy()
      test.done()
