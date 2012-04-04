AS = require("alpha_simprini")
Taxi = require("taxi")
_ = require("underscore")
{extend, isString} = _

AS.Collection = AS.Object.extend ({def, include, delegate}) ->
  include Taxi.Mixin
  delegate AS.COLLECTION_DELEGATES, to: "models"

  def initialize: (@models=[], options = {}) ->
    extend this, options
    @length = 0
    @byId = {}
    @byCid = {}
    @models = _([]).chain()
    @add(model) for model in @models

  def model: -> AS.Model

  def add: (model={}, options={}) ->
    # Allow for passing both Model and ViewModels in
    model = model.model if model.model and model.model.id

    unless model instanceof AS.Model
      model = @build(model)

    model[@inverse].set(@source) if @inverse and @source

    throw new Error("Cannot add model to collection twice.") if @models.include(model).value()
    @_add(model, options)

    model

  def build: (model) ->
    if isString(model)
      AS.All.byId[model]
    else
      if model.id and AS.All.byId[model.id]
        return AS.All.byId[model.id]
      else if model._type
        ctor = AS.module(model._type)
      else
        ctor = @model()
        
      ctor.new(model)

  def _add: (model, options={}) ->
    options.at ?= this.length
    index = options.at
    @byCid[model.cid] = @byId[model.id] = model
    @models._wrapped.splice index, 0, model
    @length++
    model.bind
      event: "all"
      namespace: @objectId()
      handler: @_onModelEvent
      context: this

    model.trigger "add", this, options

  def at: (index) ->
    @models.value()[index]

  def remove: (model, options={}) ->
    # Allow for passing both Model and ViewModels in
    model = model.model
    result = @_remove(model, options)

    model[@inverse](null) if @inverse

    result

  def _remove: (model, options={}) ->
    options.at = @models.indexOf(model).value()
    @length--
    delete @byId[model.id]
    delete @byCid[model.cid]
    @models = @models.without(model)
    model.trigger("remove", this, options)
    model.unbind
      event: "all"
      namespace: @objectId()

  # # When an event is triggered from a model, it is bubbled up through the collection.
  def _onModelEvent: (event, model, collection, options) ->
    return unless isString(event)
    return if (event is "add" or event is "remove") and (this isnt collection)
    @_remove(model, options) if event is "destroy"
    @trigger.apply(this, arguments)

#  def pluck: (name) -> @map (item) -> item[name]()
