{AS, NS, $, _, sinon, coreSetUp} = require require("path").resolve("./test/client_helper")

exports.setUp = coreSetUp

NS.Viewed = AS.Model.extend ({def}) ->
  @field "field"
  @hasMany "many"
  @hasOne "one"
  # @embeds_many "embeds"
  # @embeds_one "embed"
  # @has_many "relations"
  # @has_one "relation"
  # @belongs_to "owner"

  # @virtualProperties "field"
  #   one: ->
  #   two: ->

  def other: ->

exports.ViewModel =
  "builds viewmodels": (test) ->
    view = AS.View.new()
    model = AS.Model.new()
    vm = AS.ViewModel.build view, model

    test.equal vm.view, view
    test.equal vm.model, model

    test.done()

  "caches constructors": (test) ->
    vm1 = AS.ViewModel.build AS.View.new(), AS.Model.new()
    vm2 = AS.ViewModel.build AS.View.new(), AS.Model.new()

    test.equal vm1.constructor, vm2.constructor

    test.done()

  "configures constructor": (test) ->
    vm = AS.ViewModel.build AS.View.new(), NS.Viewed.new()
    bindables = vm.constructor.bindables

    test.equal bindables.field, AS.Binding.Field
    test.equal bindables.many, AS.Binding.Many
    test.equal bindables.one, AS.Binding.One

    test.done()
