helper = require require("path").resolve("./test/helper")
{AS, _, sinon, makeDoc, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.belongsTo "owner"

NS.Owner = AS.Model.extend ->
  @field 'name'

exports.BelongsTo =
  "property is a Field": (test) ->
    o = NS.Parent.new()
    test.ok o.owner instanceof AS.Model.Field.Instance
    test.done()

  "property is an EmbedsOne": (test) ->
    o = NS.Parent.new()
    test.ok o.owner instanceof AS.Model.BelongsTo.Instance
    test.done()

  "fetches model from AS.All if set by id": (test) ->
    o = NS.Parent.new()
    owner = NS.Owner.new()
    o.owner.set(owner.id)
    test.equal owner.id, o.owner.get().id
    test.done()

  "re-binds events when model changes": (test) ->
    test.expect(2)
    o = NS.Parent.new()
    o.owner.bind("change:name", -> test.ok(true))
    firstOwner = NS.Owner.new()
    secondOwner = NS.Owner.new()

    o.owner.set(firstOwner)
    firstOwner.name.set("Virgil")

    o.owner.set(secondOwner)
    firstOwner.name.set("Janine")
    secondOwner.name.set("Lord High Executioner")
    test.done()

  "Sharing":
    setUp: (callback) ->
      @o = NS.Parent.new()
      @share = makeDoc()
      @share.at().set {}
      @o.owner.syncWith(@share)
      callback()

    "default share value is null": (test) ->
      test.equal null, @share.at('owner').get()
      test.done()

    "value propagates from model to share": (test) ->
      owner = NS.Owner.new()
      @o.owner.set(owner)
      test.equal owner.id, @share.at("owner").get()
      test.done()

    "value propagates from share to model": (test) ->
      owner = NS.Owner.new()
      @share.emit 'remoteop', @share.at('owner').set(owner.id)
      test.equal owner.id, @o.owner.get().id
      test.done()
