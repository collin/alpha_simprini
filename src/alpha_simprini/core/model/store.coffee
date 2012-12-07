{extend, clone} = _


class AS.Model.Store  
  include Taxi.Mixin

  def initialize: ({@adapterClass, @adapterConfig}) ->
    @adapterConfig ?= {}
    @adapterConfig.store = this

  def adapterFor: (options) ->
    @adapterClass.new( extend clone(@adapterConfig), options )

  def load: (constructor, id) ->
    model = constructor.find(id)
    @adapterFor({model}).open()
    model


