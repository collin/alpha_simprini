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
        when AS.Model.HasMany
          AS.Binding.Many
        when AS.Model.HasOne
          AS.Binding.HasOne

    for method in AS.instanceMethods(model)
      continue if _.include _.keys(Pathology.Object::), method
      do (method) =>
        klass::[method] ?= -> @model[method].apply(@model, arguments)

    return klass

  def initialize: (@view, @model) ->
    @cid = @model.cid

  def binding: (field, options, fn) ->
    if _.isFunction(options)
      [fn, options] = [options, {}]

    new @constructor.bindables[field](@view, @model, field, options, fn)

  def input: (path, options) ->
    new AS.Binding.Input(@view, @model, path, options)

  def checkbox: (path, options) ->
    new AS.Binding.CheckBox(@view, @model, path, options)

  def select: (path, options) ->
    new AS.Binding.Select(@view, @model, path, options)

  def editline: (path, options) ->
    new AS.Binding.EditLine(@view, @model, path, options)
