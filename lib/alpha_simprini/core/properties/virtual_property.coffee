AS = require("alpha_simprini")
_ = require "underscore"

AS.Model.VirtualProperty = AS.Property.extend ({def}) ->
  def initialize: (@name, @_constructor, @options={}) ->
    @options.name = @name
    @_constructor.writeInheritableValue 'properties', @name, this

  def instance: (object) -> @constructor.Instance.new(object, @options)

NULL_CACHE = new Object
AS.Model.VirtualProperty.Instance = AS.Property.Instance.extend ({def}) ->
  def initialize: (@object, @options) ->
    @cached = NULL_CACHE
    for dependency in @options.dependencies
      @object.bind "change:#{dependency}",  _.bind @triggerFor, this, dependency

  def set: () -> throw "Can't set a VirtualProperty name: #{@options.name}, dependencies: #{@options.dependencies.join(',')}"
  
  def get: -> @cached ?= @compute()

  def compute: (args) -> @options.fn.call(@object)

  def triggerFor: (dependency) ->
    computed = @compute()
    return if @cached is computed
    @cached = computed
    @_trigger()

  def _trigger: ->    
    @object.trigger("change:#{@options.name}")
      

AS.Model.defs virtualProperties: (dependencies..., properties) -> 
  for name, fn of properties
    AS.Model.VirtualProperty.new(name, this, dependencies: dependencies, fn: fn)
