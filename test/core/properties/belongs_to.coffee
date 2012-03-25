helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.belongsTo "owner"

# NS.Child = NS.Parent.extend()
# NS.Child.hasMany "children", model: -> NS.Child

exports.BelongsTo =
  "property is a HasOne": (test) ->
    o = NS.Parent.new()
    test.ok o.owner instanceof AS.Model.HasOne.Instance
    test.done()

  "property is an EmbedsOne": (test) ->
    o = NS.Parent.new()
    test.ok o.owner instanceof AS.Model.BelongsTo.Instance
    test.done()
