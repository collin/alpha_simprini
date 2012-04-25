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
  "property is a HasMany": (test) ->
    o = NS.Parent.new()
    test.ok o.children instanceof AS.Model.HasMany.Instance
    test.done()

  "triggers change event when members change": (test) ->
    test.expect 2
    o = NS.Parent.new()
    o.children.bind('change', -> test.ok true)
    child = o.children.add NS.Child.new()
    child.power.set(10)
    child.toughness.set(10)
    test.done()

  "is set when constructing the model": (test) ->
    o = NS.Parent.new children: [{}]
    test.ok o.children.first().value() instanceof AS.Model
    test.done()

  "collection events trigger on property": (test) ->
    test.expect 1
    o = NS.Parent.new()
    o.children.bind "add", -> test.ok true
    o.children.add()
    test.done()

  "creates models of type speficied in options": (test) ->
    o = NS.Child.new()
    test.ok o.children.add() instanceof NS.Child
    test.done()

  "populates the inverse when item added": (test) ->
    parent = NS.Inverter.new()
    child = NS.Child.new()
    parent.children.add child
    test.equal parent, child.parent.get()
    test.done()


  "bindPath":
    "may bind through HasMany by name": (test) ->
      test.expect(2)
      o = NS.Inverter.new()
      o.bindPath ['children', 'children', 'power'], -> test.ok true

      child = o.children.add NS.Child.new()

      child.children.add().power.set("howdy")
      child2 = child.children.add()
      child2.power.set("howdy as well")

      child.children.remove(child2)
      child2.power.set("orhpan power")
      test.done()

  "Sharing":
    "on load":
      "loads objects from share": (test) ->
        shareData =
          children: [
            {_type: "NS.Child", id: _.uniqueId()}
            {_type: "NS.Child", id: _.uniqueId()}
          ]

        share = makeDoc(null, shareData)
        o = NS.Parent.new()
        o.children.syncWith(share)
        test.equal 2, o.children.backingCollection.length

        test.done()

      "doesn't re-add data to share": (test) ->
        shareData =
          children: [
            {_type: "NS.Child", id: _.uniqueId()}
            {_type: "NS.Child", id: _.uniqueId()}
          ]

        share = makeDoc(null, shareData)
        o = NS.Parent.new()
        o.children.syncWith(share)
        test.equal 2, share.at('children').get().length

        test.done()

    "propagate values from model to share on sync": (test) ->
      o = NS.Parent.new()
      child = NS.Child.new()
      share = makeDoc()
      share.at().set({})
      o.children.add(child)
      o.children.syncWith(share)
      test.deepEqual [{id: child.id}], share.at("children").get()
      test.done()

    "propagate values from share to model on sync": (test) ->
      o = NS.Parent.new()
      child = NS.Child.new()
      share = makeDoc()
      share.at().set children: [{"NS.Child", id: child.id}]
      o.children.syncWith(share)
      test.equal child.id, o.children.at(0).id

      test.done()

    setUp: (callback) ->
      @o = NS.Child.new()
      @share = makeDoc()
      @share.at().set {}
      @o.children.syncWith(@share)
      callback()

    "default share value is []": (test) ->
      test.deepEqual [], @share.at('children').get()
      test.done()

    "when an item is added to the field it is added to the share": (test) ->
      child = @o.children.add NS.Child.new()
      test.deepEqual {id:child.id}, @share.at('children', 0).get()
      test.done()

    "adds item to the share at the specified index": (test) ->
      child = @o.children.add NS.Child.new()
      child2 = @o.children.add NS.Child.new(), at: 0
      test.deepEqual {id:child2.id}, @share.at('children', 0).get()
      test.done()

    "when an item is removed from the field it is removed from the share": (test) ->
      child = @o.children.add NS.Child.new()
      @o.children.remove(child)
      test.deepEqual [], @share.at('children').get()
      test.done()

    "when an item is added to the share it is added to the field": (test) ->
      child = NS.Child.new()
      @share.emit 'remoteop', @share.at('children').insert(0, id: child.id)
      test.equal child.id, @o.children.first().value().id
      test.equal NS.Child, @o.children.first().value().constructor
      test.done()
    