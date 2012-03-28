helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, makeDoc, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.hasMany "children"

NS.Child = NS.Parent.extend()
NS.Child.hasMany "children", model: -> NS.Child

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

  "Sharing":
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
      test.equal child.id, @o.children.first().value()
      test.equal NS.Child, @o.children.first().value().constructor
      test.done()
    