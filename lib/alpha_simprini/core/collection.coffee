AS = require("alpha_simprini")
Taxi = require("taxi")
{extend, chain, isString} = require("underscore")

AS.Collection = AS.Object.extend
  initialize: (@models=[], options = {}) ->
    extend this, options
    @length = 0
    @byId = {}
    @byCid = {}
    @models = chain([])
    @add(model) for model in @models

  model: -> AS.Model

  add: (model={}, options={}) ->
    # Allow for passing both Model and ViewModels in
    model = model.model if model.model and model.model.id

    unless model instanceof AS.Model
      model = @build(model)

    model[@inverse](@source) if @inverse and @source

    throw new Error("Cannot add model to collection twice.") if @models.include(model).value()
    @_add(model, options)

    model

  build: (model) ->
    if isString(model)
      AS.All.byId[model]
    else
      if model.id and AS.All.byId[model.id]
        return AS.All.byId[model.id]
      else if model._type
        ctor = AS.module(model._type)
      else
        ctor = @model()
      ctor.create(model)

  _add: (model, options={}) ->
    options.at ?= this.length
    index = options.at
    @byCid[model.cid] = @byId[model.id] = model
    @models._wrapped.splice index, 0, model
    @length++
    model.bind
      event: "all"
      namespace: @objectId()
      handler: @_on_model_event
      context: this

    model.trigger "add", this, options

  at: (index) ->
    @models.value()[index]

  remove: (model, options={}) ->
    # Allow for passing both Model and ViewModels in
    model = model.model
    result = @_remove(model, options)

    model[@inverse](null) if @inverse

    result

  _remove: (model, options={}) ->
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
  _on_model_event: (event, model, collection, options) ->
    return unless isString(event)
    return if (event is "add" or event is "remove") and (this isnt collection[0])
    @_remove(model, options) if event is "destroy"
    @trigger.apply(this, arguments)

#   pluck: (name) -> @map (item) -> item[name]()

AS.Collection.delegate AS.COLLECTION_DELEGATES, to: "models"

Taxi.Mixin.extends(AS.Collection)
# class AS.Collection
#   AS.Delegate.extends(this)
#   AS.Event.extends(this)


#   @model: -> AS.Model

#   constructor: (@models=[]) ->
#     @initialize()

#   initialize: () ->
#     given_models = @models



#   # filter: (options) ->
#   #   @filter ?= new AS.Collection.Filter(this)
#   #   @filter.reset()
#   #   @filter.on(options)
#   #   @filter




# class AS.EmbeddedCollection extends AS.Collection
