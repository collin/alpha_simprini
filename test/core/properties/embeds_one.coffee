helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.embedsOne "embed"

# NS.Child = NS.Parent.extend()
# NS.Child.hasMany "children", model: -> NS.Child

exports.EmbedsMany =
  "property is a HasOne": (test) ->
    o = NS.Parent.new()
    test.ok o.embed instanceof AS.Model.HasOne.Instance
    test.done()

  "property is an EmbedsOne": (test) ->
    o = NS.Parent.new()
    test.ok o.embed instanceof AS.Model.EmbedsOne.Instance
    test.done()
