helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.embedsMany "embeds"

# NS.Child = NS.Parent.extend()
# NS.Child.hasMany "children", model: -> NS.Child

exports.EmbedsMany =
  "property is a HasMany": (test) ->
    o = NS.Parent.new()
    test.ok o.embeds instanceof AS.Model.HasMany.Instance
    test.done()

  "property is an EmbedsMany": (test) ->
    o = NS.Parent.new()
    test.ok o.embeds instanceof AS.Model.EmbedsMany.Instance
    test.done()
