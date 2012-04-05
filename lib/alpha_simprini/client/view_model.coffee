AS = require "alpha_simprini"
_ = require "underscore"
jQuery = require "jQuery"
Pathology = require "pathology"

AS.ViewModel = AS.Object.extend ({def, defs}) ->

  defs build: (view, model) ->
    constructor = AS.ViewModel.constructorForModel(model.constructor)
    constructor.new(view, model)

  defs constructorForModel: (model) ->
    return AS.ViewModel[model.path()] if AS.ViewModel[model.path()]

    klass = AS.ViewModel[model.path()] = AS.ViewModel.extend()
    klass.name = model.name
    klass::type = model.name

    klass.bindables = {}
    klass.extended_by = model.extended_by

    for name, property of model.properties
      klass.bindables[name] = switch property.constructor
        when AS.Model.Field
          AS.Binding.Field
        when AS.Model.BelongsTo, AS.Model.EmbedsOne, AS.Model.HasOne
          AS.Binding.One
        when AS.Model.HasMany, AS.Model.EmbedsMany
          AS.Binding.Many
        # when AS.Model.HasOne
        #   AS.Binding.HasOne

    for method in AS.instanceMethods(model)
      continue if _.include _.keys(Pathology.Object::), method
      do (method) =>
        klass::[method] ?= -> @model[method].apply(@model, arguments)

    return klass

  def initialize: (@view, @model) ->
    @cid = @model.cid
    for key, config of @model.constructor.properties
      @[key] = @model[key]

  def binding: (field, options, fn) ->
    if _.isFunction(options)
      [fn, options] = [options, {}]

    @constructor.bindables[field].new(@view, @model, @model[field], options, fn)

  def input: (field, options) ->
    AS.Binding.Input.new(@view, @model, @model[field], options)

  def checkbox: (field, options) ->
    AS.Binding.CheckBox.new(@view, @model, @model[field], options)

  # def select: (field, options) ->
  #   AS.Binding.Select.new(@view, @model, @model[field], options)

  def editline: (field, options) ->
    AS.Binding.EditLine.new(@view, @model, @model[field], options)
