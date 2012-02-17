{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")

class Viewed extends AS.Model
  @field "field"
  @embeds_many "embeds"
  @embeds_one "embed"
  @has_many "relations"
  @has_one "relation"
  @belongs_to "owner"

  @virtual_properties "field"
    one: ->
    two: ->

  other: ->

exports.ViewModel =
  "builds viewmodels": (test) ->
    view = new AS.View
    model = new AS.Model
    vm = AS.ViewModel.build view, model

    test.equal vm.view, view
    test.equal vm.model, model

    test.done()

  "caches constructors": (test) ->
    vm1 = AS.ViewModel.build new AS.View, new AS.Model
    vm2 = AS.ViewModel.build new AS.View, new AS.Model

    test.equal vm1.constructor, vm2.constructor

    test.done()

  "configures constructor": (test) ->
    vm = AS.ViewModel.build new AS.View, new Viewed
    bindables = vm.constructor.bindables

    test.equal bindables.field, AS.Binding.Field
    test.equal bindables.embeds, AS.Binding.EmbedsMany
    test.equal bindables.embed, AS.Binding.EmbedsOne
    test.equal bindables.relations, AS.Binding.HasMany
    test.equal bindables.relation, AS.Binding.HasOne
    test.equal bindables.owner, AS.Binding.BelongsTo
    test.equal bindables.one, AS.Binding.Field
    test.equal bindables.one, AS.Binding.Field

    test.done()

  "delegates all model methods to model": (test) ->
    vm = AS.ViewModel.build new AS.View, new Viewed

    delegate = new RegExp

    for method in "field embeds embed relations relation owner other".split(" ")
      test.ok vm[method].toString().indexOf("return this.model[method].apply(this.model, arguments);")

    test.done()
