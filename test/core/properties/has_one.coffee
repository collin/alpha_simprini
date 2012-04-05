helper = require require("path").resolve("./test/helper")
{AS, _, sinon, coreSetUp, RelationModel, FieldModel, NS} = helper
exports.setUp = coreSetUp

NS.Parent = AS.Model.extend()
NS.Parent.hasOne "other", model: -> NS.Other

NS.Other = NS.Parent.extend()
NS.Other.field "name"

exports.HasOne = 
  "property is a HasOne": (test) ->
    o = NS.Parent.new()
    test.ok o.other instanceof AS.Model.HasOne.Instance
    test.done()

  "is set when constructing the model": 
    "with a model": (test) ->
      o = NS.Parent.new other: other = AS.Model.new()
      test.equal other, o.other.get()
      test.done()

    "with a raw abject": (test) ->
      o = NS.Parent.new other: name: "Linus"
      test.equal "Linus", o.other.get().name.get()
      test.done()

  "bindPath":
    "may bind through hasOne by name": (test) ->
      test.expect 2
      otherother = NS.Other.new()
      other = NS.Other.new(other:otherother)
      o = NS.Parent.new other: other

      o.bindPath ['other', 'other', 'name'], -> test.ok(true)

      otherother.name.set("other from another other's mother")

      other.other.set newother = NS.Other.new()

      otherother.name.set "simpler name"
      newother.name.set "new name"
      test.done()

    "may bind through ancestral hierarchy": (test) ->
      test.expect 2
      otherother = NS.Other.new()
      other = NS.Other.new(other:otherother)
      o = NS.Parent.new other: other

      o.bindPath ['other', NS.Parent, 'name'], -> test.ok(true)

      otherother.name.set("other from another other's mother")

      other.other.set newother = NS.Other.new()

      otherother.name.set "simpler name"
      newother.name.set "new name"
      test.done()

  "collection events trigger on property": (test) ->
    test.expect 1
    o = NS.Parent.new other: name: "Juliet"
    o.other.get().name.bind "change", -> test.ok true
    o.other.get().name.set "Julio"
    test.done()

  "change event triggers when model is set": (test) ->
    test.expect 3, "fix field pass-through binding"
    o = NS.Parent.new()
    o.bind "change", -> test.ok true
    o.bind "change:other", -> test.ok true
    o.other.bind "change", -> test.ok true
    o.other.set {}
    test.done()

  "clears object when set to null": (test) ->
    test.expect 4, "fix field pass-through binding"
    o = NS.Parent.new()
    o.bind "change", -> test.ok true
    o.bind "change:other", -> test.ok true
    o.other.bind "change", -> test.ok true
    o.other.set null
    test.equal undefined, o.other.get()
    test.done()
