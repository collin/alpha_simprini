AS = exports.AS = require "alpha_simprini"
_ = exports._ = require "underscore"
sinon = exports.sinon = require "sinon"
$ = exports.$ = require "jquery"
exports.jwerty = require("jwerty").jwerty
AS.suppress_logging()

exports.coreSetUp = (callback) ->
  AS.All =
    byCid: {}
    byId: {}
  callback()

exports.makeDoc = (name="document_name", snapshot=null) ->
  share = require "share"
  Doc = share.client.Doc
  doc = new Doc {}, name, 0, share.types.json, snapshot
  # FIXME: get proper share server running in the tests
  # as it is we seem to be able to skip over the "pendingOp" stuff
  # but it'd be nicer to properly test his out.
  doc.submitOp = (op, callback) ->
    op = @type.normalize(op) if @type.normalize?
    @snapshot = @type.apply @snapshot, op
    #
    # # If this throws an exception, no changes should have been made to the doc
    #
    # if pendingOp != null
    #   pendingOp = @type.compose(pendingOp, op)
    # else
    #   pendingOp = op
    #
    pendingCallbacks.push callback if callback
    #
    @emit 'change', op
    #
    # # A timeout is used so if the user sends multiple ops at the same time, they'll be composed
    # # together and sent together.
    setTimeout @flush, 0
    op
    # console.log op, callback
  doc


class exports.FieldModel extends AS.Model
  @field "name"

class exports.RelationModel extends AS.Model
  @embeds_many "embeds"
  @embeds_one "embed"
  @has_many "relations"
  @has_one "relation"
  @belongs_to "owner"


global.document = $("body")[0]._ownerDocument
global.window = document._parentWindow


