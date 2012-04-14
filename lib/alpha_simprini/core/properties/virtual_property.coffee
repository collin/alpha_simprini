AS = require("alpha_simprini")
_ = require "underscore"

AS.Model.VirtualProperty = AS.Model.Field.extend ({def}) ->
  def initialize: (@name, @_constructor, @options={}) ->
    @options.name = @name
    @dependencies = @options.dependencies
    @_constructor.writeInheritableValue 'properties', @name, this

  def instance: (object) -> @constructor.Instance.new(object, @options)

NULL_CACHE = new Object
AS.Model.VirtualProperty.Instance = AS.Property.Instance.extend ({def}) ->
  def initialize: (@object, @options) ->
    @cached = NULL_CACHE
    for dependency in @options.dependencies
      @object[dependency].bind "add", _.bind(@triggerFor, this, dependency, "add")
      @object[dependency].bind "remove", _.bind(@triggerFor, this, dependency, "remove")
      @object[dependency].bind "change", _.bind(@triggerFor, this, dependency, "change")

  def set: (value) -> 
    if set = @options.getSet.set
      set.call(@object, value)
    else
      throw "Can't set a VirtualProperty name: #{@options.name}, dependencies: #{@options.dependencies.join(',')}"
  
  def get: -> @cached = @compute()

  def compute: (args) -> @options.getSet.get.call(@object)

  def triggerFor: (dependency, trigger) ->
    computed = @compute()
    return if @cached is computed
    @cached = computed
    @_trigger()

  def _trigger: ->
    @trigger("change")
    @object.trigger("change")
    @object.trigger("change:#{@options.name}")
      

AS.Model.defs virtualProperties: (dependencies..., properties) -> 
  for name, fn of properties
    if _.isFunction(fn)
      getSet = {get: fn}
    else
      getSet = fn
    AS.Model.VirtualProperty.new(name, this, dependencies: dependencies, getSet: getSet)
