class NS.AView < AS.View
class NS.Viewed < AS.Model
  @field "field"
  @hasMany "many"
  @hasOne "one"
  # @embeds_many "embeds"
  # @embeds_one "embed"
  # @has_many "relations"
  # @has_one "relation"
  # @belongsTo "owner"

  # @virtualProperties "field"
  #   one: ->
  #   two: ->

  def other: ->

module "ViewModel"
test "builds viewmodels", ->
  view = NS.AView.new()
  model = NS.Viewed.new()
  vm = AS.ViewModel.build view, model

  equal vm.view, view
  equal vm.model, model


test "caches constructors", ->
  vm1 = AS.ViewModel.build NS.AView.new(), NS.Viewed.new()
  vm2 = AS.ViewModel.build NS.AView.new(), NS.Viewed.new()

  equal vm1.constructor, vm2.constructor


test "configures constructor", ->
  vm = AS.ViewModel.build NS.AView.new(), NS.Viewed.new()
  bindables = vm.constructor.bindables

  equal bindables.field, AS.Binding.Field
  equal bindables.many, AS.Binding.Many
  equal bindables.one, AS.Binding.One

  