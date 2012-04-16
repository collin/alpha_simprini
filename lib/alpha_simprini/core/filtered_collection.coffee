# How would you implement this such that the @parent/@filter property could be changed?
#
# perhaps.. something like this?
# 
# @property "parent"
# @property "filter"

# @virtualProperty "parent", "filter",
#   models:
#     get: ->
#     set: ->
#     add: ->
#     remove: ->
AS = require "alpha_simprini"
Taxi = require "taxi"
{extend, isString, isFunction, isArray} = require "underscore"

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

  def determinePlacementInSelf: (model) ->
    if @filter(model) is true
      @addToSelf(model)
    else
      @removeFromSelf(model)

  def addToSelf: (model) ->
    return if @models.include(model).value()
    @_add(model)

  def removeFromSelf: (model) ->
    return unless @models.include(model).value()
    @_remove(model)

  def reFilter: ->
    @parent.each (model) => @determinePlacementInSelf(model)

  def setConditions: (conditions) ->
    @conditions.unbind()
    @conditions.set(key, value) for key, value of conditions
    @conditions.bind 
      event: 'change'
      handler: @reFilter
      context: this
    @reFilter()

  def filter: (model) ->
    for key, value of @conditions.toObject()
      modelValue = model[key].get()
      testValue = if isFunction(value) then value.call() else value
      testValue = if isArray(testValue) then testValue else [testValue]

      return false unless modelValue in testValue

    true

    

