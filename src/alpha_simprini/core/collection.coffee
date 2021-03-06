{extend, isString} = _

class AS.Collection
  include Taxi.Mixin
  delegate AS.COLLECTION_DELEGATES, to: "models"

  def initialize: (@models=[], options = {}) ->
    extend this, options
    @length = 0
    @byId = {}
    @byCid = {}
    @models = _([]).chain()
    @add(model) for model in @models
  # @::initialize.doc =
  #   params: [
  #     ["@models", [AS.Model], false, default: []]
  #     ["options", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def model: -> AS.Model
  # @::model.doc =
  #   desc: """
  #
  #   """

  def add: (model={}, options={}) ->
    # Allow for passing both Model and ViewModels in
    model = model.model if model.model and model.model.id

    unless model instanceof AS.Model
      model = @build(model)

    model[@inverse].set(@source) if @inverse and @source

    @_add(model, options)

    model
  # @::add.doc =
  #   params: [
  #     ["model", [AS.Model, String, Object], false, default: {}]
  #     ["options", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def build: (model) ->
    if isString(model) and constructor = @model?()
      return constructor.find(model)
    else if isString(model)
      AS.All.byId[model]
    else
      if model.id and AS.All.byId[model.id]
        return AS.All.byId[model.id]
      else
        ctor = @model()

      data = _.clone(model)
      ctor.new(data)
  # @::build.doc =
  #   private: true
  #   params: [
  #     ["model", [AS.Model, String, Object], true]
  #   ]
  #   desc: """
  #
  #   """

  def _add: (model, options={}) ->
    options.at ?= @length

    index = options.at
    @byCid[model.cid] = @byId[model.id] = model

    if @models.include(model).value()
      console.warn "Cannot add model to collection twice.", model.toString() 
    else
      @models._wrapped.splice index, 0, model
      @length++
      model.bind
        event: "all"
        namespace: @objectId()
        handler: @_onModelEvent
        context: this

      model.trigger "add", this, options
  # @::_add.doc =
  #   private: true
  #   params: [
  #     ["model", AS.Model, true]
  #     ["options", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def prev: (model) ->
    @at @indexOf(model).value() - 1

  def next: (model) ->
    @at @indexOf(model).value() + 1

  def after: (reference, model) ->
    @remove model
    @add model, at: @indexOf(reference).value() + 1

  def before: (reference, model) ->
    @remove model
    @add model, at: @indexOf(reference).value()

  def at: (index) ->
    @models.value()[index]
  # @::at.doc =
  #   params: [
  #     ["index", Number, true]
  #   ]
  #   desc: """
  #
  #   """

  def remove: (model, options={}) ->
    # Allow for passing both Model and ViewModels in
    model = model.model
    result = @_remove(model, options)

    model[@inverse].set(null) if @inverse

    result
  # @::remove.doc =
  #   params: [
  #     ["model", AS.Model, true]
  #     ["options", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def _remove: (model, options={}) ->
    options.at = @models.indexOf(model).value()
    if @models.include(model).value()
      @length--
      delete @byId[model.id]
      delete @byCid[model.cid]
      @models = @models.without(model)
      model.trigger("remove", this, options)
      model.unbind
        event: "all"
        namespace: @objectId()
    else
      console.warn "Cannot remove model from collection twice.", model?.toString() 

  # @::_remove.doc =
  #   private: true
  #   params: [
  #     ["model", AS.Model, true]
  #     ["options", {}, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def filter: (filterBy) ->
    AS.FilteredCollection.new(this, filterBy)
  # @::filter.doc =
  #   params: [
  #     ["filterBy", {}, true]
  #   ]
  #   return: AS.FilteredCollection
  #   desc: """
  #
  #   """

  def groupBy: (key, metaData) ->
    AS.Models.Grouping.new(this, key, metaData)
  # @::groupBy.doc =
  #   params: [
  #     ["key", String, true]
  #     ["metaData", Object, false]
  #   ]
  #   desc: """
  #
  #   """

  # # When an event is triggered from a model, it is bubbled up through the collection.
  def _onModelEvent: (event, model, collection, options) ->
    return unless isString(event)
    return if (event is "add" or event is "remove") and (this isnt collection)
    @_remove(model, options) if event is "destroy"
    @trigger.apply(this, arguments)
  # @::_onModelEvent.doc =
  #   private: true
  #   params: [
  #     ["event", String, true]
  #     ["model", AS.Model, true]
  #     ["collection", AS.Collection, false]
  #     ["options", Object, false]
  #   ]
  #   desc: """
  #
  #   """

#  def pluck: (name) -> @map (item) -> item[name]()
