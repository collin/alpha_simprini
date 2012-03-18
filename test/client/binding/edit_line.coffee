{AS, NS, $, _, sinon, makeDoc, BoundModel,
SimpleModel, mock_binding, coreSetUp} = require require("path").resolve("./test/client_helper")
exports.setUp = coreSetUp

exports.Binding =
 EditLine:
    setUp: (callback) ->
      @rangy_api =
        getSelection: -> {
            rangeCount: 0
            createRange: -> {
              startOffset: 0
              endOffset: 0
            }
          }
        createRange: -> {
          startOffset: 0
          endOffset: 0
        }

      @real_open = AS.open_shared_object
      AS.open_shared_object = (id, did_open) ->
        did_open makeDoc(id)

      @remote = (operation, model = @model) ->
        if model.share.emit
          model.share.emit "remoteop", operation
        else
          model.share.doc.emit "remoteop", operation

      AS.Binding.EditLine::rangy = @rangy_api
      callback()

    tearDown: (callback) ->
      AS.open_shared_object = @real_open
      callback()

    # TODO: implement sharing things
    # "contenteditable area responds to all edit events": (test) ->
    #   test.expect 8
    #   EditLine = AS.Binding.EditLine.extend ({def}) ->
    #     def generate_operation: -> test.ok true
    #   [mocks, binding] = mock_binding(EditLine)
    #   mocks.binding.expects("applyChange").exactly(0)
    #   for event in ['textInput', 'keydown', 'keyup', 'select', 'cut', 'paste', 'click', 'focus']
    #     binding.content.trigger(event)
    #   mocks.verify()
    #   test.done()

    # "applies change if content has changed on edit event": (test) ->
    #   model = SharedBoundModel.open()
    #   model.field("value")
    #   model.when_indexed =>
    #     [mocks, binding] = mock_binding(AS.Binding.EditLine, model: model)
    #     binding.content[0].innerHTML += " change"
    #     binding.generate_operation()
    #     test.deepEqual model.share.get(), model.attributes_for_sharing()
    #     test.done()

    # "applies change from remote operation": (test) ->
    #   model = SharedBoundModel.open()
    #   model.field("value")
    #   model.when_indexed =>
    #     [mocks, binding] = mock_binding(AS.Binding.EditLine, model: model)
    #     @remote model.share.at("field").insert(0, "remote "), model
    #     test.equal binding.content[0].innerHTML, "remote value"
    #     test.equal model.share.at("field").get(), "remote value"
    #     test.equal model.field(), "remote value"
    #     test.done()