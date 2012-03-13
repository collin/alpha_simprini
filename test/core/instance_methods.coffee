{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

exports.InstanceMethods =
  discoversInstanceMethods: (test) ->
    HasMethods = AS.Object.extend ({def}) ->
      def a: 1
      def b: 2

      test.deepEqual AS.instanceMethods(HasMethods), ["a", "b"]
      test.done()

  traversesClasses: (test) ->
    A = AS.Object.extend ({def}) ->
      def a: 1

    B = A.extend ({def}) ->
      def b: 2

      test.deepEqual AS.instanceMethods(B), ["b", "a"]
      test.done()
