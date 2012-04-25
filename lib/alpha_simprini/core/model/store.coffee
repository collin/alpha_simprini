AS = require("alpha_simprini")
Taxi = require("taxi")
{extend, clone} = require("underscore")

AS.Model.Store = AS.Object.extend ({delegate, include, def, defs}) ->
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

    
