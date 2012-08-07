AS.Model.VirtualProperty = AS.Model.Field.extend ({def}) ->
  def initialize: (@name, @_constructor, @options={}) ->
    @options.name = @name
    @dependencies = @options.dependencies
    @_constructor.writeInheritableValue 'properties', @name, this
  # @::initialize.doc =
  #   params: [
  #     ["@name", String, true]
  #     ["@_constructor", AS.Object, true]
  #     ["@options", Object, true]
  #   ]
  #   desc: """
  #
  #   """

  def instance: (object) -> @constructor.Instance.new(object, @options)
  # @::instance.doc =
  #   params: [
  #     ["object", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

NULL_CACHE = new Object
AS.Model.VirtualProperty.Instance = AS.Property.Instance.extend ({def}) ->
  def initialize: (@object, @options) ->
    @cached = NULL_CACHE
    @bindDependencies()
  # @::initialize.doc =
  #   params: [
  #     ["@object", AS.Model, true]
  #     ["@options", Object, true]
  #   ]
  #   desc: """
  #
  #   """

  def bindDependencies: ->
    for dependency in @options.dependencies
      @object[dependency].addDependant(this)
  # @::bindDependencies.doc =
  #   desc: """
  #
  #   """

  def set: (value) ->
    if set = @options.getSet.set
      set.call(@object, value)
      @triggerDependants()
    else
      AS.warn "Can't set a VirtualProperty name: #{@options.name}, dependencies: #{@options.dependencies.join(',')}"
  # @::set.doc =
  #   params: [
  #     [value, "*", true]
  #   ]
  #   desc: """
  #
  #   """

  def get: -> @cached = @compute()
  # @::get.doc =
  #   return: "*"
  #   desc: """
  #
  #   """

  def compute: (args) -> @options.getSet.get.call(@object)
  # @::compute.doc =
  #   private: true
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def objects: ->
    [@get()]
  # @::objects.doc =
  #   desc: """
  #     For virtual properties, 'objects' is an Array containing the computed value.
  #   """

  def triggerFor: () ->
    # JUST LET THINGS GO TO HELL. WE NEED A RUNLOOP AND DIRTY TRACKING I GUESS ):(
    # computed = @compute()
    # return if @cached is computed
    # @cached = computed
    @trigger("change")
    @object.trigger("change")
    @object.trigger("change:#{@options.name}")
  # @::triggerFor.doc =
  #   private: true
  #   desc: """
  #
  #   """

  def rawValue: null

AS.Model.defs virtualProperties: (dependencies..., properties) ->
  for name, fn of properties
    if _.isFunction(fn)
      getSet = {get: fn}
    else
      getSet = fn
    AS.Model.VirtualProperty.new(name, this, dependencies: dependencies, getSet: getSet)
