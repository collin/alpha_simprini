AS = require "alpha_simprini"
_ = require "underscore"
sinon = require "sinon"

exports.setUp = (callback) ->
  AS.All =
    byCid: {}
    byId: {}
  callback()

exports.core = 
  testIdentity: (test) ->
    test.ok AS.Identity(10)(10)
    test.done()
  
  constructorIdentity: (test) ->
    class Fake
    test.ok AS.ConstructorIdentity(Fake)(new Fake)
    test.done()
  
  deepClone: (test) ->
    test.notEqual AS.deep_clone(it = []), it
    test.notEqual AS.deep_clone(it = {}), it
    
    test.deepEqual AS.deep_clone(it = []), it
    test.deepEqual AS.deep_clone(it = {}), it
    
    it = [
      {a: 134, 3: [2, {}, [], [], "FOO"]},
      23
      "BAR"
    ]
    test.deepEqual AS.deep_clone(it), it
    not_it = AS.deep_clone(it)
    not_it.push "BAZ"
    test.notDeepEqual it, not_it
    
    test.done()
  
  uniq: (test) ->
    test.ok AS.uniq().match /^.*-.*-.*$/
    test.notEqual AS.uniq(), AS.uniq()
    test.done()
  
  humanSize: (test) ->
    sz = AS.human_size
    
    test.equal sz(100), "100.0 B"
    
    for prefix, index in ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
      test.equal sz(Math.pow(1024, index + 1)), "1.0 #{prefix}"
    test.done()
  
Target = null
SubTarget = null
Source = null
exports.mixin =
  setUp: (callback) ->
    delete Target
    class Target
    Source = new AS.Mixin
    Source.extends(Target)
    
    callback()
  
  tearDown: (callback) ->
    delete Target
    delete Source
    callback()
  
  targetExtendedBySource: (test) ->    
    test.ok Source.extended(Target)
    test.ok Source.extended(new Target)
        
    test.done()
  
  inheritanceDoesntLeakUpward: (test) ->
    Source2 = new AS.Mixin
    class SubTarget extends Target
    Source2.extends(SubTarget)
    
    test.ok not(Source2.extended(Target))
    test.done()
  
  dependencies: (test) ->
    A = new AS.Mixin
    B = new AS.Mixin depends_on: [A]
    
    klass = {}
    
    B.extends(klass)
    
    test.ok A.extended(klass)
    
    test.done()
  
  mixedInCallback: (test) ->
    test.expect(1)
    mixin = new AS.Mixin mixed_in: -> test.ok(true)
    it = {}
    mixin.extends it
    mixin.extends it
    
    test.done()
  
  methodsMixIn: (test) ->
    mixin = new AS.Mixin
      class_methods: a: 1
      instance_methods: b: 2
    
    mixin.extends Target
    
    test.equal Target.a, 1
    test.equal (new Target).b, 2
    test.done()

class Parent
  AS.InheritableAttrs.extends(this)
  @push_inheritable_item "ancestors", "Grandpa"
  @write_inheritable_value "preferences", "food", "everything"
  
class Child extends Parent
  @extended()
  @push_inheritable_item "ancestors", "Dad"
  @write_inheritable_value "preferences", "food", "nothing"

Parent.write_inheritable_value "preferences", "this", "that"

exports.inheritable_attrs =
  childHasParentsAttrs: (test) ->
    test.deepEqual Child.ancestors, ["Grandpa", "Dad"]
    test.deepEqual Child.preferences, "food": "nothing"
    test.done()
  
  childValuesDontLeakUpwards: (test) ->
    test.deepEqual Parent.ancestors, ["Grandpa"]
    test.deepEqual Parent.preferences, this: "that", "food": "everything"
    test.done()

class Delegator
  AS.Delegate.extends(this)
  @delegate "property", to: "propertydelegate"
  @delegate "method", to: "methoddelegate"
  
  propertydelegate: property: (arg) -> "value #{arg}"
  
  
exports.delegate =
  propertyDelegate: (test) ->
    test.equal "value 2", (new Delegator).property("2")
    test.done()
  
  # methodDelegate: (test) ->
  #   test.ok false, "method delegates not used yet"
  #   # console.log Object.keys(test)
  #   # test.equal "value", (new Delegator).method()
  #   test.done()

class Car
  AS.StateMachine.extends(this)
  
  constructor: -> @default_state "off"
  
exports.StateMachine =
  hasDefaultState: (test) ->
    test.equal (new Car).state, "off"
    test.done()
  
  "will not transition from the wrong state": (test) ->
    car = new Car
    car.transition_state from: "wrongstate", to: "on"
    test.equal car.state, "off"
    test.done()
  
  "calls transition method with options for a valid transition": (test) ->
    test.expect 2
    car = new Car
    car.exit_off = (options) ->
      test.deepEqual from: "off", to: "on", options
    
    car.enter_on = (options) ->
      test.deepEqual from: "off", to: "on", options
    
    car.transition_state from: "off", to: "on"
    
    test.done()
  
exports.InstanceMethods =
  discoversInstanceMethods: (test) ->
    class HasMethods
      a: 1
      b: 2
    
      test.deepEqual AS.instance_methods(HasMethods), ["a", "b"]
      test.done()
      
  traversesClasses: (test) ->
    class A
      a: 1
      
    class B extends A
      b: 2
    
      test.deepEqual AS.instance_methods(B), ["b", "a"]
      test.done()

class WithCallbacks
  AS.Callbacks.extends(this)
  @define_callbacks
    before: "this that".split(" ")
  
exports.Callbacks =
  definition: (test) ->
    it = WithCallbacks
    test.ok WithCallbacks.before_this
    test.ok WithCallbacks.before_that
    test.done()
  
  running: (test) ->
    test.expect(2)
    
    it = WithCallbacks
    cb = -> test.ok(true)
    it.before_this cb
    it.before_that cb
    
    one = new WithCallbacks
    one.run_callbacks "before_this"
    one.run_callbacks "before_that"
    
    test.done()

class FieldModel extends AS.Model
  @field "name"

class RelationModel extends AS.Model
  @embeds_many "embeds"
  @embeds_one "embed"
  @has_many "relations"
  @has_one "relation"
  @belongs_to "owner"

class Evented
  AS.Event.extends(this)
  
exports.Event =
  "trigger events without namespace": (test) ->
    test.expect 3
    o = new Evented
    o.bind "event.namespace", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true
    o.trigger "event"
    
    test.done()
    
  "trigger events with namespace": (test) ->
    test.expect 1
    o = new Evented
    o.bind "event2.namespace2", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true
    o.trigger "event.namespace2"
    o.trigger ".namespace2"
  
    test.done()
    
  "unbind events without namespace": (test) ->
    test.expect 1
    o = new Evented
    o.bind "event.namespace", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true
    o.unbind ".namespace2"
    o.unbind "event.namespace"
    o.trigger "event"
    o.trigger "event2"
    
    test.done()
    
  "unbind events with namespace": (test) ->
    o = new Evented

    test.expect 2
    
    o.bind "event.namespace", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true
    
    o.unbind(".namespace2")
    o.trigger "event"
    
    test.done()
  
  "unbind all events": (test) ->
    o = new Evented

    test.expect 0
    
    o.bind "event.namespace", -> test.ok true
    o.bind "event.namespace2", -> test.ok true
    o.bind "event", -> test.ok true
    
    o.unbind()
    o.trigger "event"
    
    test.done()

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

class Shared extends AS.Model
  AS.Model.Share.extends(this)
  @_type = "Shared"
  @field "field"
  @embeds_many "embeds", model: -> SimpleShare
  @embeds_one "embedded", model: -> SimpleShare
  @has_many "relations", model: -> SimpleShare
  @has_one "relation"
  @belongs_to "owner"

class SimpleShare extends AS.Model
  @_type = "SimpleShare"
  AS.Model.Share.extends(this)
  @field "field"

class IndexShare extends AS.Model
  @_type = "IndexShare"
  AS.Model.Share.extends(this)
  @index "docs"
  @belongs_to "owner"

makeDoc = (name="document_name", snapshot=null) ->
  share = require "share"
  Doc = share.client.Doc
  doc = new Doc {}, name, 0, share.types.json, snapshot
  # FIXME: get proper share server running in the tests
  # as it is we seem to be able to skip over the "pendingOp" stuff
  # but it'd be nicer to properly test his out.
  doc.submitOp = (op, callback) ->
    op = @type.normalize(op) if @type.normalize?
    @snapshot = @type.apply @snapshot, op
    #     
    # # If this throws an exception, no changes should have been made to the doc
    #     
    # if pendingOp != null
    #   pendingOp = @type.compose(pendingOp, op)
    # else
    #   pendingOp = op
    #     
    pendingCallbacks.push callback if callback
    #     
    @emit 'change', op
    #     
    # # A timeout is used so if the user sends multiple ops at the same time, they'll be composed
    # # together and sent together.
    setTimeout @flush, 0
    op
    # console.log op, callback
  doc
  
exports.Model.Share =
  setUp: (callback) ->
    @real_open = AS.open_shared_object
    @real_module = AS.module
    AS.module = (name) ->
      return {
        "SimpleShare": SimpleShare,
        "Shared": Shared,
        "IndexShare": IndexShare
      }[name]
    AS.open_shared_object = (id, did_open) ->
      did_open makeDoc(id)
    
    @remote = (operation) ->
      @model.share.emit "remoteop", operation
    
    (@model = Shared.open()).when_indexed callback
    
  tearDown: (callback) ->
    AS.open_shared_object = @real_open
    AS.module = @real_module
    callback()
    
  "sets initial attribuets when opening an object": (test) -> 
    test.deepEqual @model.share.get(), @model.attributes_for_sharing()
    test.done()
  
  "updates shared object when model attributes change": (test) ->
    @model.field("VALUE")
    test.equal @model.share.at("field").get(), "VALUE"
      
    test.done()
  
  "adds/removes items to relations in share": (test) ->
    @model.relations().add SimpleShare.open()
    @model.embeds().add SimpleShare.open()
    @model.embedded SimpleShare.open()
    @model.owner SimpleShare.open()
    
    test.deepEqual @model.relations().first().value().attributes_for_sharing(), @model.share.at("relations", 0).get()
    test.deepEqual @model.embeds().first().value().attributes_for_sharing(), @model.share.at("embeds", 0).get()
    test.deepEqual @model.embedded().attributes_for_sharing(), @model.share.at("embedded").get()
    test.equal @model.attributes.owner, @model.share.at("owner").get()
    test.notEqual @model.owner(), undefined
      
    @model.relations().remove @model.relations().first().value()
    @model.embeds().remove @model.embeds().first().value()
    @model.embedded null
    @model.owner null
    
    test.equal @model.share.at("relations", 0).get(), undefined
    test.equal @model.share.at("embeds", 0).get(), undefined
    test.equal @model.share.at("embedded").get(), undefined
    test.equal @model.share.at("owner").get(), undefined
    
    test.done()
  
  "adds items to shared collection at specified index": (test) ->
    @model.relations().add SimpleShare.open()
    @model.embeds().add SimpleShare.open()

    @model.relations().add first_relation = SimpleShare.open(), at: 0
    @model.embeds().add first_embed = SimpleShare.open(), at: 0
    
    test.deepEqual first_relation.attributes_for_sharing(), @model.share.at("relations", 0).get()
    test.deepEqual first_embed.attributes_for_sharing(), @model.share.at("embeds", 0).get()
      
    test.done()
  
  "updates fields when fields change on share": (test) ->
    test.expect 2
    @model.bind "change:field", -> test.ok true
    @remote @model.share.at("field").set("value")
    test.equal @model.field(), "value"
    test.done()
  
  "updates fields in embeds_one models when change occurs on share": (test) ->
    test.expect 5
    
    @model.embedded first = SimpleShare.open()    
    @model.embedded().bind "change:field", -> test.ok true
    @remote @model.share.at("embedded", "field").set("value")
    test.equal first.field(), "value"

    # make sure when we swap out embeds the only the newer one is changed
    @model.embedded second = SimpleShare.open()    
    @model.embedded().bind "change:field", -> test.ok true
    @remote @model.share.at("embedded", "field").set("value2")
    test.notEqual first.field(), "value2"
    test.equal second.field(), "value2"
    
    test.done()
  
  "updates fields in embeds_many models when change occurs on share": (test) ->
    test.expect 2
    
    @model.embeds().add first = SimpleShare.open()    
    first.bind "change:field", -> test.ok true
    @remote @model.share.at("embeds", 0, "field").set("value")
    test.equal first.field(), "value"

    test.done()
  
  "updates belongs_to in has_many models when change occurs on share": (test) ->
    test.expect 2
    owner = SimpleShare.open()
    @model.bind "change:owner", -> test.ok true
    @remote @model.share.at("owner").set(owner.id)
    test.equal @model.owner(), owner

    test.done()

  "loads models when indexes update": (test) ->
    (@model = IndexShare.open()).when_indexed =>
      (other = SimpleShare.open()).when_indexed  =>
        AS.open_shared_object = (id, did_open) -> did_open other.share
        @model.bind "indexload", (loaded) =>
          loaded.when_indexed ->
            test.done()
        @remote @model.share.at("index:docs", other.id).set("SimpleShare")

  "loads models in indexes when opened": (test) ->
    indexed = new SimpleShare
    index = {}
    index[indexed.id] = "SimpleShare"
    delete AS.All.byId[indexed.id]
    delete AS.All.byCid[indexed.cid]
    snap = {}
    snap["index:docs"] = index
    snap["owner"] = indexed.id
    doc = makeDoc(AS.uniq(), snap)

    @model = new IndexShare
    
    AS.open_shared_object = (id, did_open) ->
      did_open makeDoc(id, indexed.attributes_for_sharing())
    
    @model.did_open(doc)
    @model.when_indexed =>
      test.notEqual AS.All.byId[indexed.id], undefined
      test.equal @model.owner(), AS.All.byId[indexed.id]
      test.done()
    
exports.Collection =
  "inserts item of specified type": (test) ->
    class Thing extends AS.Model
    class ThingCollection extends AS.Collection
      model: -> Thing
    
    things = new ThingCollection
    things.add()
    
    # test.ok things.first().value() instanceof Thing
    test.done()
  
  "inserts item at a specified index": (test)->
    things = new AS.Collection
    
    things.add()
    things.add()
    
    thing = things.add({}, at: 1)
    
    test.equal things.length, 3
    test.equal things.at(1), thing
    
    test.done()
  
  "remove item from collection": (test) ->
    things = new AS.Collection
    thing = things.add()
    things.remove(thing)
    test.equal things.length, 0
    test.done()
    
  Events:
    "add event": (test) ->
      test.expect 1
      collection = new AS.Collection
      collection.bind "add", -> test.ok true
      collection.add()
      test.done()
      
    "remove event": (test) ->
      test.expect 1
      collection = new AS.Collection
      thing = collection.add()
      collection.bind "remove", -> test.ok true
      collection.remove(thing)
      test.done()
    
    "model change events bubble through collection": (test) ->
      test.expect 2
      collection = new AS.Collection
      thing = collection.add()
      collection.bind "all", -> test.ok true
      collection.bind "modelevent", -> test.ok true
      
      thing.trigger "modelevent"
      
      test.done()
    
    "add/remove evends capture on collection": (test) ->
      test.expect 2
      thing = new AS.Model
      collection = new AS.Collection
      thing.bind "add", -> test.ok true
      thing.bind "remove", -> test.ok true
      
      collection.add(thing)
      collection.remove(thing)
      
      test.done()

exports["AS.Models.RadioSelectionModel belongs_to selected"] = (test) ->
  test.ok AS.Models.RadioSelectionModel.belongs_tos.selected
  model = new AS.Models.RadioSelectionModel
  test.equal model.selected(), null
  test.done()