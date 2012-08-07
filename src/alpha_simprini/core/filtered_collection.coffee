{extend, isString, isFunction, isArray} = _

# Order in a FilteredCollection is not guaranteed to match the order
# af the Collection being filtered.
AS.FilteredCollection = AS.Collection.extend ({delegate, include, def, defs}) ->
  delegate 'add', 'remove', to: 'parent'

  def initialize: (@parent, conditions={}) ->
    @_super()

    @conditions = Taxi.Map.new()
    @conditions.set(key, value) for key, value of conditions

    @conditions.bind
      event: 'change'
      handler: @reFilter
      context: this

    @parent.bind
      event: 'add'
      handler: @determinePlacementInSelf
      context: this
      namespace: @objectId()

    @parent.bind
      event: 'change'
      handler: @determinePlacementInSelf
      context: this
      namespace: @objectId()

    @parent.bind
      event: 'remove'
      handler: @removeFromSelf
      context: this
      namespace: @objectId()

    @reFilter()
  # @::initialize.doc =
  #   params: [
  #     ["@parent", AS.Collection, true]
  #     ["conditions", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def determinePlacementInSelf: (model) ->
    if @filter(model) is true
      @addToSelf(model)
    else
      @removeFromSelf(model)
  # @::determinePlacementInSelf.doc =
  #   params: [
  #     ["model", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  def addToSelf: (model) ->
    return if @models.include(model).value()
    @_add(model)
  # @::addToSelf.doc =
  #   params: [
  #     [model, AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  def removeFromSelf: (model) ->
    return unless @models.include(model).value()
    @_remove(model)
  # @::removeFromSelf.doc =
  #   params: [
  #     [model, AS.Modle, true]
  #   ]
  #   desc: """
  #
  #   """

  def reFilter: ->
    @parent.each (model) => @determinePlacementInSelf(model)
  # @::reFilter.doc =
  #   desc: """
  #
  #   """

  def setConditions: (conditions) ->
    @conditions.unbind()
    @conditions.set(key, value) for key, value of conditions
    @conditions.bind
      event: 'change'
      handler: @reFilter
      context: this
    @reFilter()
  # @::setConditions.doc =
  #   params: [
  #     ["conditions", Object, true]
  #   ]
  #   desc: """
  #
  #   """

  def filter: (model) ->
    for key, value of @conditions.toObject()
      modelValue = model[key].get()
      testValue = if isFunction(value) then value.call() else value
      testValue = if isArray(testValue) then testValue else [testValue]

      return false unless modelValue in testValue

    true
  # @::filter.doc =
  #   params: [
  #     ["model", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """



