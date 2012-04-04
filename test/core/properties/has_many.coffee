helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, makeDoc, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.hasMany "children"

NS.Inverter = AS.Model.extend()
NS.Inverter.hasMany "children", inverse: "parent"

NS.Child = NS.Parent.extend()
NS.Child.hasMany "children", model: -> NS.Child
NS.Child.property "parent"

exports.HasMany =
  "property is a HasMany": (test) ->
    o = NS.Parent.new()
    test.ok o.children instanceof AS.Model.HasMany.Instance
    test.done()

  "is set when constructing the model": (test) ->
    o = NS.Parent.new children: {}
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


  "Sharing":
    "propagate values from model to share on sync": (test) ->
      o = NS.Parent.new()
      child = NS.Child.new()
      share = makeDoc()
      share.at().set({})
      o.children.add(child)
      o.children.syncWith(share)
      test.deepEqual [{_type: "NS.Child", id: child.id}], share.at("children").get()
      test.done()

    "propagate values from share to model on sync": (test) ->
      o = NS.Parent.new()
      child = NS.Child.new()
      share = makeDoc()
      share.at().set children: [{_type: "NS.Child", id: child.id}]
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
      test.deepEqual {id:child.id, _type:"NS.Child"}, @share.at('children', 0).get()
      test.done()

    "adds item to the share at the specified index": (test) ->
      child = @o.children.add NS.Child.new()
      child2 = @o.children.add NS.Child.new(), at: 0
      test.deepEqual {id:child2.id, _type:"NS.Child"}, @share.at('children', 0).get()
      test.done()

    "when an item is removed from the field it is removed from the share": (test) ->
      child = @o.children.add NS.Child.new()
      @o.children.remove(child)
      test.deepEqual [], @share.at('children').get()
      test.done()

    "when an item is added to the share it is added to the field": (test) ->
      child = NS.Child.new()
      @share.emit 'remoteop', @share.at('children').insert(0, id: child.id, _type:"NS.Child")
      test.equal child.id, @o.children.first().value().id
      test.equal NS.Child, @o.children.first().value().constructor
      test.done()
    