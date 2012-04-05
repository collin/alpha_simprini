{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
  One:
    setUp: (callback) ->
      @model = BoundModel.new( owner: BoundModel.new() )

      content_fn = (thing) -> @div id: thing.cid

      [mocks, binding] = mock_binding(AS.Binding.One, field: @model.owner, model: @model, fn: content_fn)

      @binding = binding
      callback()

    "creates initial dom": (test) ->
      test.ok @binding.container.find("##{@model.owner.get().cid}").is("div")
      test.done()

    "clears dom when field is null": (test) ->
      @binding.model.owner.set(null)
      test.equal undefined, @model.owner.get()
      test.equal "", @binding.container.html()
      test.done()

    "passes a model binding to the content_fn": (test) ->
      @binding.fn = (model, binding) -> 
        test.equal AS.Binding.Model, binding.constructor
        test.done()

      @binding.setContent()