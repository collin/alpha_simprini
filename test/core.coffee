{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

exports.utilities =
  testIdentity: (test) ->
    test.ok AS.Identity(10)(10)
    test.done()

  constructorIdentity: (test) ->
    class Fake
    test.ok AS.ConstructorIdentity(Fake)(new Fake)
    test.done()

  deepClone: (test) ->
    test.notEqual AS.deepClone(it = []), it
    test.notEqual AS.deepClone(it = {}), it

    test.deepEqual AS.deepClone(it = []), it
    test.deepEqual AS.deepClone(it = {}), it

    it = [
      {a: 134, 3: [2, {}, [], [], "FOO"]},
      23
      "BAR"
    ]
    test.deepEqual AS.deepClone(it), it
    not_it = AS.deepClone(it)
    not_it.push "BAZ"
    test.notDeepEqual it, not_it

    test.done()

  uniq: (test) ->
    test.ok AS.uniq().match /^.*-.*-.*$/
    test.notEqual AS.uniq(), AS.uniq()
    test.done()

  humanSize: (test) ->
    sz = AS.humanSize

    test.equal sz(100), "100.0 B"

    for prefix, index in ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
      test.equal sz(Math.pow(1024, index + 1)), "1.0 #{prefix}"
    test.done()
