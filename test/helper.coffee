AS = exports.AS = require "alpha_simprini"

NS = exports.NS = AS.Namespace.new("NS")
_ = exports._ = require "underscore"
sinon = exports.sinon = require "sinon"
$ = exports.$ = require "jquery"
exports.jwerty = require("jwerty").jwerty
# AS.suppress_logging()

require("nodeunit").assert.AssertionError.prototype.toString = ->
  if @message
    "#{@name}: #{@message}"
  else
    [
      "#{@name}:"
      @expected.toString()
      @operator
      @actual.toString()
    ].join(" ")

exports.coreSetUp = (callback) ->
  AS.All =
    byCid: {}
    byId: {}
    byIdRef: {}
  callback()

BoundModel = exports.BoundModel = NS.BoundModel = AS.Model.extend()

BoundModel.field "field"
BoundModel.field "maybe", type: Boolean
BoundModel.hasMany "items", model: -> SimpleModel
BoundModel.hasOne "owner"

# class SharedBoundModel extends BoundModel
#   AS.Model.Share.extends this, "ShareBoundModel"

SimpleModel = exports.SimpleModel = NS.SimpleModel = AS.Model.extend()
SimpleModel.field "field"

exports.mock_binding = (binding_class, _options={}) ->
  context = _options.context or AS.View.new()
  model = _options.model or BoundModel.new field: "value"
  field = _options.field or model["field"]
  options = _options.options or {}
  fn = _options.fn or undefined

  binding = binding_class.new context, model, field, options, fn

  mocks =
    binding: sinon.mock binding
    context: sinon.mock context
    model: sinon.mock model
    field: sinon.mock field
    options: sinon.mock options
    fn: sinon.mock options
    verify: ->
      @binding.verify()
      @context.verify()
      @model.verify()
      @field.verify()
      @options.verify()
      @fn.verify()

   [mocks, binding]


exports.makeDoc = (name="document_name-#{_.uniqueId()}", snapshot=null) ->
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


# class exports.FieldModel extends AS.Model
#   @field "name"

# class exports.RelationModel extends AS.Model
#   @embeds_many "embeds"
#   @embeds_one "embed"
#   @has_many "relations"
#   @has_one "relation"
#   @belongsTo "owner"


global.document = $("body")[0]._ownerDocument
global.window = document._parentWindow


