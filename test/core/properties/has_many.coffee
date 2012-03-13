helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel, NS} = helper
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
    