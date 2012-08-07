HM = Pathology.Namespace.new("HasMany")
HM.Parent = AS.Model.extend()
HM.Parent.hasMany "children"

HM.DependantParent = AS.Model.extend ({delegate, include, def, defs}) ->
  @hasMany "children", dependant: "destroy"

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
  Taxi.Governer.exit()
  child.toughness.set(10)
  Taxi.Governer.exit()

test "destroys dependant children", ->
  expect 2
  o = HM.DependantParent.new()
  c1 = o.children.add HM.Child.new()
  c2 = o.children.add HM.Child.new()

  c1.bind "destroy", => ok true
  c2.bind "destroy", => ok true

  o.destroy()

  Taxi.Governer.exit()

test "is set when constructing the model", ->
  o = HM.Parent.new children: [{}]
  ok o.children.first().value() instanceof AS.Model

test "collection events trigger on property", ->
  expect 1
  o = HM.Parent.new()
  o.children.bind "add", -> ok true
  o.children.add()
  Taxi.Governer.exit()

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
    expect 4
    o = HM.Inverter.new()

    child = o.children.add HM.Child.new()
    o.bindPath ['children', 'children', 'power'], -> ok true

    child.children.add().power.set("howdy")
    child2 = child.children.add()
    Taxi.Governer.exit()

    child2.power.set("howdy as well")
    Taxi.Governer.exit()

    child.children.remove(child2)
    child2.power.set("orhpan power")
    Taxi.Governer.exit()

test "triggers handler when hasMany segment changes", ->
  expect 1
  o = HM.Inverter.new()
  child = o.children.add HM.Child.new()
  grandChild = child.children.add()

  o.bindPath ['children', 'children'], -> ok true

  child.power.set("12")
  Taxi.Governer.exit()

module "Sharing on load",
  setup: ->
    @o = HM.Child.new()

    snap = "HasMany.Child": {}
    snap["HasMany.Child"][@o.id] = {}

    @doc = makeDoc(null, snap)
    @doc.open = -> # Avoid talking to ShareJS over the wire
    adapter = AS.Model.ShareJSAdapter.new("url", "documentName")
    adapter.document = @doc
    adapter.bindRemoteOperationHandler()

    @subDoc = @doc.at(["HasMany.Child", @o.id])
    adapter.register(@o)
    @o.children.syncWith(@subDoc)


# FIXME: sharedata is now ID only
# test "loads objects from share", ->
#   shareData =
#     children: [
#       {_type: "HasMany.Child", id: _.uniqueId()}
#       {_type: "HasMany.Child", id: _.uniqueId()}
#     ]

#   share = makeDoc(null, shareData)
#   o = HM.Parent.new()
#   o.children.syncWith(share)
#   equal 2, o.children.backingCollection.length


test "doesn't re-add data to share", ->
    shareData =
      children: [
        _.uniqueId()
        _.uniqueId()
      ]

    share = makeDoc(null, shareData)
    o = HM.Parent.new()
    o.children.syncWith(share)
    equal 2, share.at('children').get().length

test "propagate values from share to model on sync", ->
  o = HM.Parent.new()
  child = HM.Child.new()
  share = makeDoc()
  share.at().set children: [child.id]
  o.children.syncWith(share)
  equal child.id, o.children.at(0).id

test "default share value is undefined", ->
  deepEqual undefined, @subDoc.at('children').get()

test "when an item is added to the field it is added to the share", ->
  child = @o.children.add HM.Child.new()
  Taxi.Governer.exit()
  deepEqual child.id, @subDoc.at('children', 0).get()

test "adds item to the share at the specified index", ->
  child = @o.children.add HM.Child.new()
  child2 = @o.children.add HM.Child.new(), at: 0
  Taxi.Governer.exit()
  deepEqual child2.id, @subDoc.at('children', 0).get()

test "when an item is removed from the field it is removed from the share", ->
  child = @o.children.add HM.Child.new()
  @o.children.remove(child)
  Taxi.Governer.exit()
  deepEqual @subDoc.at('children').get(), undefined

test "when an item is added to the share it is added to the field", ->
  child = HM.Child.new()
  @subDoc.at('children').set([])
  @doc.emit 'remoteop', @subDoc.at('children').insert(0, child.id)
  equal child.id, @o.children.first().value().id
  equal HM.Child, @o.children.first().value().constructor

test "when an item is removed from the share it is removed from the field", ->
  child = @o.children.add HM.Child.new()
  Taxi.Governer.exit()
  @doc.emit 'remoteop', @subDoc.at('children', 0).remove()
  equal @o.children.at(0), undefined

test "when data is already in the model", ->
    @o = HM.Child.new()
    @o.children.add()

    @doc = makeDoc(null, {})
    @doc.open = -> # Avoid talking to ShareJS over the wire
    adapter = AS.Model.ShareJSAdapter.new("url", "documentName")
    adapter.document = @doc
    adapter.bindRemoteOperationHandler()

    adapter.register(@o)

    console.log @o.children
    equal @o.children.share.get().length, 1
    equal @o.children.count(), 1
