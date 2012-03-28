helper = require require("path").resolve("./test/helper")
{AS, _, sinon, makeDoc, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.embedsOne "embed"

NS.Child = NS.Parent.extend ->
  @include AS.Model.Share
  @field "name"

exports.EmbedsOne =
  "property is a HasOne": (test) ->
    o = NS.Parent.new()
    test.ok o.embed instanceof AS.Model.HasOne.Instance
    test.done()

  "property is an EmbedsOne": (test) ->
    o = NS.Parent.new()
    test.ok o.embed instanceof AS.Model.EmbedsOne.Instance
    test.done()

  "Sharing":
    setUp: (callback) ->
      @o = NS.Parent.new()
      @share = makeDoc()
      @share.at().set {}
      @o.embed.syncWith(@share)
      callback()

    "stashes @share with path": (test) ->
      test.deepEqual ['embed'], @o.embed.share.path
      test.done()

    "default value is null": (test) ->
      test.equal null, @o.embed.get()
      test.done()

    "syncs model with @share when value is set": (test) ->
      child = NS.Child.new()
      @o.embed.set(child)
      test.deepEqual @share.at("embed"), child.share
      test.done()

    "stops syncing model whith @share when value is re-set": (test) ->
      child = NS.Child.new()
      child.stopSync = -> test.done()
      child2 = NS.Child.new()
      @o.embed.set(child)
      @o.embed.set(child2)
