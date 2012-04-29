helper = require require("path").resolve("./test/helper")
{AS, _, sinon, makeDoc, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.belongsTo "owner", model: -> NS.Owner
NS.Parent.field "name"

NS.Owner = NS.Parent.extend()
# NS.Owner.

module "BelongsTo"
test "property is a Field", ->
  o = NS.Parent.new()
  ok o.owner instanceof AS.Model.Field.Instance
  
test "property is an BelongsTo", ->
  o = NS.Parent.new()
  ok o.owner instanceof AS.Model.BelongsTo.Instance
  
test "fetches model from AS.All if set by id", ->
  o = NS.Parent.new()
  owner = NS.Owner.new()
  o.owner.set(owner.id)
  equal owner.id, o.owner.get().id
    
  # "re-binds events when model changes", ->
  #   expect(2)
  #   o = NS.Parent.new()
  #   o.owner.name.bind("change:name", -> ok(true))
  #   firstOwner = NS.Owner.new()
  #   secondOwner = NS.Owner.new()

  #   o.owner.set(firstOwner)
  #   firstOwner.name.set("Virgil")

  #   o.owner.set(secondOwner)
  #   firstOwner.name.set("Janine")
  #   secondOwner.name.set("Lord High Executioner")
  #   
module "BelongsTo.bindPath"
test "may bind through belongsTo by name", ->
  expect 2
  otherother = NS.Owner.new()
  other = NS.Owner.new(owner:otherother)
  o = NS.Parent.new owner: other

  o.bindPath ['owner', 'owner', 'name'], -> ok(true)

  otherother.name.set("other from another other's mother")

  other.owner.set newother = NS.Owner.new()

  otherother.name.set "simpler name"
  newother.name.set "new name"
  
test "may bind through belongsTo by constructor", ->
  expect 2
  otherother = NS.Owner.new()
  other = NS.Owner.new(owner:otherother)
  o = NS.Parent.new owner: other

  o.bindPath ['owner', NS.Parent, 'name'], -> ok(true)

  otherother.name.set("other from another other's mother")

  other.owner.set newother = NS.Owner.new()

  otherother.name.set "simpler name"
  newother.name.set "new name"
      

module "BelongsTo Sharing"
"propagates field value to share on sync", ->
  o = NS.Parent.new()
  owner = NS.Owner.new()
  share = makeDoc()
  share.at().set({})
  o.owner.set(owner)
  o.owner.syncWith(share)

  deepEqual owner.id, share.at('owner').get()
  
test "propagates share value to field on sync", ->
  o = NS.Parent.new()
  owner = NS.Owner.new()
  share = makeDoc()
  share.at().set({})
  share.at('owner').set(owner.id)
  o.owner.syncWith(share)
  equal owner.id, o.owner.get().id

  
setUp: (callback) ->
  @o = NS.Parent.new()
  @share = makeDoc()
  @share.at().set {}
  @o.owner.syncWith(@share)
  callback()

test "default share value is null", ->
  equal "", @share.at('owner').get()
  
test "value propagates from model to share", ->
  owner = NS.Owner.new()
  @o.owner.set(owner)
  equal owner.id, @share.at("owner").get()
  
test "value propagates from share to model", ->
  owner = NS.Owner.new()
  @share.emit 'remoteop', @share.at('owner').set(owner.id)
  equal owner.id, @o.owner.get().id
  