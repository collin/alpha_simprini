helper = require require("path").resolve("./test/helper")
{AS, _, sinon, makeDoc, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.embedsMany "embeds", model: -> NS.Child
NS.Parent.include AS.Model.Share

NS.Child = AS.Model.extend()
NS.Child.include AS.Model.Share

exports.EmbedsMany =
  "property is a HasMany": (test) ->
    o = NS.Parent.new()
    test.ok o.embeds instanceof AS.Model.HasMany.Instance
    test.done()

  "property is an EmbedsMany": (test) ->
    o = NS.Parent.new()
    test.ok o.embeds instanceof AS.Model.EmbedsMany.Instance
    test.done()

  Sharing:
    "on sync": 
      "propagates value from field to share": (test) ->
        o = NS.Parent.new()
        child = NS.Child.new()
        o.embeds.add(child)
        share = makeDoc()
        share.at().set({})
        o.embeds.syncWith(share)

        test.deepEqual [{_type: "NS.Child", id:child.id}], share.at('embeds').get()
        test.done()

      "propagates value from share to field": (test) ->
        o = NS.Parent.new()
        child = NS.Child.new()
        share = makeDoc()
        share.at().set embeds: [{_type: "NS.Child", id:child.id}]
        o.embeds.syncWith(share)
        test.equal child.toString(), o.embeds.backingCollection.at(0).toString()
        test.done()

    setUp: (callback) ->
      @o = NS.Parent.new()
      @share = makeDoc()
      @share.at().set {}
      @o.embeds.syncWith(@share)
      callback()

    "stashes @share with path": (test) ->
      test.deepEqual ['embeds'], @o.embeds.share.path
      test.done()

    "default share value is []": (test) ->
      test.deepEqual [], @share.at('embeds').get()
      test.done()

    "calls didEmbed on models as they are inserted": (test) ->
      child = NS.Child.new()
      child.didEmbed = (share) -> 
        test.deepEqual ['embeds', 0], share.path
        test.done()
      @o.embeds.add(child)

    "calls stopSync on models as they are removed": (test) ->
      child = NS.Child.new()
      child.stopSync = -> test.done()
      @o.embeds.add(child)
      @o.embeds.remove(child)

