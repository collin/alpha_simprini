AS = require("alpha_simprini")
_ = require "underscore"

class AS.Collection
  AS.Delegate.extends(this)
  AS.Event.extends(this)

  @delegate "first", "rest", "last", "compact", "flatten", "without", "union", "filter", "reverse",
            "intersection", "difference", "uniq", "zip", "indexOf", "find", "detect", "at",
            "lastIndexOf", "range", "include",  "each", "map", "reject","all", "toArray", to: "models"

  @model: -> AS.Model

  constructor: (@models=[]) ->
    @initialize()

  initialize: () ->
    given_models = @models
    @length = 0
    @byId = {}
    @byCid = {}
    @models = _([]).chain()
    @add(model) for model in given_models

  at: (index) ->
    @models.value()[index]

  add: (model={}, options={}) ->
    # Allow for passing both Model and ViewModels in
    model = model.model if model.model and model.model.id

    unless model instanceof AS.Model
      model = @build(model)

    # console.log "adding", model, "to", this if model.constructor.name is "Box"
    model[@inverse](@source) if @inverse and @source

    throw new Error("Cannot add model to collection twice.") if @models.include(model).value()
    @_add(model, options)

    model

  _add: (model, options={}) ->
    options.at ?= this.length
    index = options.at
    @byCid[model.cid] = @byId[model.id] = model
    @models._wrapped.splice index, 0, model
    @length++
    model.bind("all", @_on_model_event, this)
    model.trigger "add", this, options

  # filter: (options) ->
  #   @filter ?= new AS.Collection.Filter(this)
  #   @filter.reset()
  #   @filter.on(options)
  #   @filter

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
    model.unbind("all", @_on_model_event)

  build: (model) ->
    if _.isString(model)
      AS.All.byId[model]
    else
      if model.id and AS.All.byId[model.id]
        return AS.All.byId[model.id]
      else if model._type
        ctor = AS.module(model._type)
      else
        ctor = @constructor.model()
      new ctor(model)

  # When an event is triggered from a model, it is bubbled up through the collection.
  _on_model_event: (event, model, collection, options) ->
    # FIXME: should be looking for an event [path]
    return unless _.isString(event)
    return if (event is "add" or event is "remove") and (this isnt collection)
    @_remove(model, options) if event is "destroy"
    @trigger.apply(this, arguments)

  pluck: (name) -> @map (item) -> item[name]()

class AS.EmbeddedCollection extends AS.Collection
