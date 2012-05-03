HM = Pathology.Namespace.new("HasMany")
HM.Parent = AS.Model.extend()
HM.Parent.hasMany "children"

HM.Inverter = AS.Model.extend()
HM.Inverter.hasMany "children", inverse: "parent", model: HM.Child

HM.Child = HM.Parent.extend()
HM.Child.hasMany "children", model: -> HM.Child
HM.Child.field "power"
HM.Child.field "toughness"
HM.Child.property "parent"

makeDoc = NS.makeDoc

module "HasMany"
test "property is a HasMany", ->
  o = HM.Parent.new()
  ok o.children instanceof AS.Model.HasMany.Instance

test "triggers change event when members change", ->
  expect 2
  o = HM.Parent.new()
  o.children.bind('change', -> ok true)
  child = o.children.add HM.Child.new()
  child.power.set(10)
  child.toughness.set(10)

test "is set when constructing the model", ->
  o = HM.Parent.new children: [{}]
  ok o.children.first().value() instanceof AS.Model

test "collection events trigger on property", ->
  expect 1
  o = HM.Parent.new()
  o.children.bind "add", -> ok true
  o.children.add()

test "creates models of type speficied in options", ->
  o = HM.Child.new()
  ok o.children.add() instanceof HM.Child

test "populates the inverse when item added", ->
  parent = HM.Inverter.new()
  child = HM.Child.new()
  parent.children.add child
  equal parent, child.parent.get()

module "bindPath"
test "may bind through HasMany by name", ->
    expect(2)
    o = HM.Inverter.new()
    o.bindPath ['children', 'children', 'power'], -> ok true

    child = o.children.add HM.Child.new()

    child.children.add().power.set("howdy")
    child2 = child.children.add()
    child2.power.set("howdy as well")

    child.children.remove(child2)
    child2.power.set("orhpan power")

module "Sharing on load",
  setup: ->
    @o = HM.Child.new()
    @share = makeDoc()
    @share.at().set {}
    @o.children.syncWith(@share)

test "loads objects from share", ->
  shareData =
    children: [
      {_type: "HM.Child", id: _.uniqueId()}
      {_type: "HM.Child", id: _.uniqueId()}
    ]

  share = makeDoc(null, shareData)
  o = HM.Parent.new()
  o.children.syncWith(share)
  equal 2, o.children.backingCollection.length


test "doesn't re-add data to share", ->
    shareData =
      children: [
        {_type: "HM.Child", id: _.uniqueId()}
        {_type: "HM.Child", id: _.uniqueId()}
      ]

    share = makeDoc(null, shareData)
    o = HM.Parent.new()
    o.children.syncWith(share)
    equal 2, share.at('children').get().length


test "propagate values from model to share on sync", ->
  o = HM.Parent.new()
  child = HM.Child.new()
  share = makeDoc()
  share.at().set({})
  o.children.add(child)
  o.children.syncWith(share)
  deepEqual [child.id], share.at("children").get()

test "propagate values from share to model on sync", ->
  o = HM.Parent.new()
  child = HM.Child.new()
  share = makeDoc()
  share.at().set children: [{"HM.Child", id: child.id}]
  o.children.syncWith(share)
  equal child.id, o.children.at(0).id

test "default share value is []", ->
  console.log @share.get()
  deepEqual [], @share.at('children').get()

test "when an item is added to the field it is added to the share", ->
  child = @o.children.add HM.Child.new()
  deepEqual {id:child.id}, @share.at('children', 0).get()

test "adds item to the share at the specified index", ->
  child = @o.children.add HM.Child.new()
  child2 = @o.children.add HM.Child.new(), at: 0
  deepEqual {id:child2.id}, @share.at('children', 0).get()

test "when an item is removed from the field it is removed from the share", ->
  child = @o.children.add HM.Child.new()
  @o.children.remove(child)
  deepEqual [], @share.at('children').get()

test "when an item is added to the share it is added to the field", ->
  child = HM.Child.new()
  @share.emit 'remoteop', @share.at('children').insert(0, id: child.id)
  equal child.id, @o.children.first().value().id
  equal HM.Child, @o.children.first().value().constructor
      