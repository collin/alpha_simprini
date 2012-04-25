AS = require("alpha_simprini")
_ = require "underscore"

AS.Model.VirtualProperty = AS.Model.Field.extend ({def}) ->
  # @::initialize.doc = 
  #   params: [
  #     ["@name", String, true]
  #     ["@_constructor", AS.Object, true]
  #     ["@options", Object, true]
  #   ]
  #   desc: """
  #     
  #   """
  def initialize: (@name, @_constructor, @options={}) ->
    @options.name = @name
    @dependencies = @options.dependencies
    @_constructor.writeInheritableValue 'properties', @name, this

  # @::instance.doc = 
  #   params: [
  #     ["object", AS.Model, true]
  #   ]
  #   desc: """
  #     
  #   """
  def instance: (object) -> @constructor.Instance.new(object, @options)

NULL_CACHE = new Object
AS.Model.VirtualProperty.Instance = AS.Property.Instance.extend ({def}) ->
  # @::initialize.doc = 
  #   params: [
  #     ["@object", AS.Model, true]
  #     ["@options", Object, true]
  #   ]
  #   desc: """
  #     
  #   """
  def initialize: (@object, @options) ->
    @cached = NULL_CACHE
    @bindDependencies()

  # @::bindDependencies.doc = 
  #   desc: """
  #     
  #   """
  def bindDependencies: ->
    for dependency in @options.dependencies
      @object[dependency].addDependant(this)

  # @::set.doc = 
  #   params: [
  #     [value, "*", true]
  #   ]
  #   desc: """
  #     
  #   """
  def set: (value) -> 
    if set = @options.getSet.set
      set.call(@object, value)
    else
      throw "Can't set a VirtualProperty name: #{@options.name}, dependencies: #{@options.dependencies.join(',')}"
  
  # @::get.doc = 
  #   return: "*"
  #   desc: """
  #     
  #   """
  def get: -> @cached = @compute()

  # @::compute.doc = 
  #   private: true
  #   params: [
  #     []
  #   ]
  #   desc: """
  #     
  #   """
  def compute: (args) -> @options.getSet.get.call(@object)

  # @::triggerFor.doc = 
  #   private: true
  #   desc: """
  #     
  #   """
  def triggerFor: () ->
    # JUST LET THINGS GO TO HELL. WE NEED A RUNLOOP AND DIRTY TRACKING I GUESS ):(
    # computed = @compute()
    # return if @cached is computed
    # @cached = computed
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
