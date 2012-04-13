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
{extend, isString} = require "underscore"

AS.FilteredCollection = AS.Collection.extend ({delegate, include, def, defs}) ->
  delegate 'add', 'remove', to: 'parent'
  @property 'filter'

  def initialize: (@parent, filter=(-> true)) ->
    @_super()

    @filter.bind 
      event: 'change'
      handler: @reFilter
      context: this

    @parent.bind
      event: 'add'
      handler: @determinePlacementInSelf
      context: this
      namespace: @objectId()

    @parent.bind 
      event: 'remove'
      handler: @determinePlacementInSelf
      context: this
      namespace: @objectId()

    @filter.set(filter)

  def determinePlacementInSelf: (model) ->
    if @filter.get()(model) is true
      @addToSelf(model)
    else
      @removeFromSelf(model)

  def addToSelf: (model) ->
    return if @models.include(model).value()
    model.unbind "."+@objectId()

    model.bind
      event: "change"
      handler: @determinePlacementInSelf
      namespace: @objectId()
      context: this

    @_add(model)

  def removeFromSelf: (model) ->
    model.unbind "." + @objectId()
    return unless @models.include(model).value()
    @_remove(model)
    # FIXME: thish should trigger on the previous method
    @trigger("remove", model)

  def reFilter: ->
    @parent.each (model) => @determinePlacementInSelf(model)

    

