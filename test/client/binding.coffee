{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  "stashes the binding container": (test) ->
    [mocks, binding] = mock_binding(AS.Binding)

    test.equal binding.container[0], binding.context.currentNode

    test.done()

  "stashes the binding group": (test) ->
    [mocks, binding] = mock_binding(AS.Binding)
    test.equal binding.bindingGroup, binding.context.bindingGroup

    test.done()

  "gets the field value": (test) ->
    [mocks, binding] = mock_binding(AS.Binding)
    test.equal binding.fieldValue(), "value"

    test.done()

  # Collection:
  #   "field_value is the model": (test) ->
  #     [mocks, binding] = mock_binding(AS.Binding.Many, model: new AS.Collection)
  #     test.equal binding.pathValue(), binding.model
  #     test.done()

  # HasOne:
  #   "extends AS.Binding.Field": (test) ->
  #     test.equal AS.Binding.HasOne.__super__.constructor, AS.Binding.Field
  #     test.done()

  # BelongsTo:
  #   setUp: (callback) ->
  #     owner = new AS.Model
  #     model = new BoundModel
  #     model.owner owner

  #     content_fn = (thing) -> @div id: thing.cid

  #     [mocks, binding] = mock_binding(AS.Binding.BelongsTo, field: 'owner', model: model, fn: content_fn)

  #     @owner = owner
  #     @binding = binding
  #     callback()

  #   "initializes content": (test) ->
  #     test.ok @binding.container.find("##{@owner.cid}").is("div")
  #     test.done()

  #   "removes content when relation set to null": (test) ->
  #     @binding.model.owner(null)
  #     test.equal @binding.container.html(), ""
  #     test.done()

  #   "creates content when relation set": (test) ->
  #     new_owner = new AS.Model
  #     @binding.model.owner new_owner
  #     test.ok @binding.container.find("##{new_owner.cid}").is("div")
  #     test.done()
