helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, makeDoc, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.hasMany "children"

NS.Inverter = AS.Model.extend()
NS.Inverter.hasMany "children", inverse: "parent", model: NS.Child

NS.Child = NS.Parent.extend()
NS.Child.hasMany "children", model: -> NS.Child
NS.Child.field "power"
NS.Child.field "toughness"
NS.Child.property "parent"

exports.HasMany =
test "property is a HasMany", ->
  o = NS.Parent.new()
  ok o.children instanceof AS.Model.HasMany.Instance
  
test "triggers change event when members change", ->
  expect 2
  o = NS.Parent.new()
  o.children.bind('change', -> ok true)
  child = o.children.add NS.Child.new()
  child.power.set(10)
  child.toughness.set(10)
  
test "is set when constructing the model", ->
  o = NS.Parent.new children: [{}]
  ok o.children.first().value() instanceof AS.Model
  
test "collection events trigger on property", ->
  expect 1
  o = NS.Parent.new()
  o.children.bind "add", -> ok true
  o.children.add()
  
test "creates models of type speficied in options", ->
  o = NS.Child.new()
  ok o.children.add() instanceof NS.Child
  
test "populates the inverse when item added", ->
  parent = NS.Inverter.new()
  child = NS.Child.new()
  parent.children.add child
  equal parent, child.parent.get()
  

test "bindPath":
test "may bind through HasMany by name", ->
    expect(2)
    o = NS.Inverter.new()
    o.bindPath ['children', 'children', 'power'], -> ok true

    child = o.children.add NS.Child.new()

    child.children.add().power.set("howdy")
    child2 = child.children.add()
    child2.power.set("howdy as well")

    child.children.remove(child2)
    child2.power.set("orhpan power")
      
module "Sharing on load"
test "loads objects from share", ->
  shareData =
    children: [
      {_type: "NS.Child", id: _.uniqueId()}
      {_type: "NS.Child", id: _.uniqueId()}
    ]

  share = makeDoc(null, shareData)
  o = NS.Parent.new()
  o.children.syncWith(share)
  equal 2, o.children.backingCollection.length

    
test "doesn't re-add data to share", ->
    shareData =
      children: [
        {_type: "NS.Child", id: _.uniqueId()}
        {_type: "NS.Child", id: _.uniqueId()}
      ]

    share = makeDoc(null, shareData)
    o = NS.Parent.new()
    o.children.syncWith(share)
    equal 2, share.at('children').get().length

    
test "propagate values from model to share on sync", ->
  o = NS.Parent.new()
  child = NS.Child.new()
  share = makeDoc()
  share.at().set({})
  o.children.add(child)
  o.children.syncWith(share)
  deepEqual [{id: child.id}], share.at("children").get()
  
test "propagate values from share to model on sync", ->
  o = NS.Parent.new()
  child = NS.Child.new()
  share = makeDoc()
  share.at().set children: [{"NS.Child", id: child.id}]
  o.children.syncWith(share)
  equal child.id, o.children.at(0).id

  
setUp: (callback) ->
  @o = NS.Child.new()
  @share = makeDoc()
  @share.at().set {}
  @o.children.syncWith(@share)
  callback()

test "default share value is []", ->
  deepEqual [], @share.at('children').get()
  
test "when an item is added to the field it is added to the share", ->
  child = @o.children.add NS.Child.new()
  deepEqual {id:child.id}, @share.at('children', 0).get()
  
test "adds item to the share at the specified index", ->
  child = @o.children.add NS.Child.new()
  child2 = @o.children.add NS.Child.new(), at: 0
  deepEqual {id:child2.id}, @share.at('children', 0).get()
  
test "when an item is removed from the field it is removed from the share", ->
  child = @o.children.add NS.Child.new()
  @o.children.remove(child)
  deepEqual [], @share.at('children').get()
  
test "when an item is added to the share it is added to the field", ->
  child = NS.Child.new()
  @share.emit 'remoteop', @share.at('children').insert(0, id: child.id)
  equal child.id, @o.children.first().value().id
  equal NS.Child, @o.children.first().value().constructor
      