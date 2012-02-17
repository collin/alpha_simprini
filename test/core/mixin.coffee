{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

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
