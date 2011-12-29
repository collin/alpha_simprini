AS = require "alpha_simprini"
_ = require "underscore"
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
  
  openSharedObject: (test) ->
    test.ok false, "Not sure how to mock out sharejs for this test, sorry."
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
  
  methodDelegate: (test) ->
    test.ok false, "method delegates not used yet"
    # console.log Object.keys(test)
    # test.equal "value", (new Delegator).method()
    test.done()

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
      
      
      
      
      
      
      
      
      
      