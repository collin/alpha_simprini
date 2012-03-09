AS = require("alpha_simprini")
_ = require "underscore"
jQuery = require "jQuery"

AS.ViewModel = AS.Object.extend()

  # @build: (view, model) ->
  #   constructor = AS.ViewModel.constructor_for_model(model.constructor)
  #   new constructor(view, model)

  # @constructor_for_model: (model) ->
  #   # Setting a cid on the constructor prevents name collisions
  #   model.cid ?= _.uniqueId("ctor")
  #   key = "#{model.name}-#{model.cid}"
  #   return AS.ViewModel[key] if AS.ViewModel[key]

  #   klass = class AS.ViewModel[key] extends AS.ViewModel
  #   klass.name = model.name
  #   klass::type = model.name

  #   klass.bindables = {}
  #   klass.extended_by = model.extended_by

  #   klass.field(field) for field, __ of model.fields if model.fields
  #   klass.field(virtual) for virtual, __ of model.virtuals if model.virtuals
  #   klass.embeds_many(embed_many) for embed_many, __ of model.embeds_manys if model.embeds_manys
  #   klass.embeds_one(embed_one) for embed_one, __ of model.embeds_ones if model.embeds_ones
  #   klass.has_many(has_many) for has_many, __ of model.has_manys if model.has_manys
  #   klass.has_one(has_one) for has_one, __ of model.has_ones if model.has_ones
  #   klass.belongs_to(belongs_to) for belongs_to, __ of model.belongs_tos if model.belongs_tos

  #   klass.delegations(model)

  #   klass

  # @field: (name) ->
  #   @bindables[name] = AS.Binding.Field

  # @embeds_many: (name) ->
  #   @bindables[name] = AS.Binding.EmbedsMany

  # @embeds_one: (name) ->
  #   @bindables[name] = AS.Binding.EmbedsOne

  # @has_many: (name) ->
  #   @bindables[name] = AS.Binding.HasMany

  # @has_one: (name) ->
  #   @bindables[name] = AS.Binding.HasOne

  # @belongs_to: (name) ->
  #   @bindables[name] = AS.Binding.BelongsTo

  # @delegations: (model) ->
  #   for method in AS.instance_methods(model)
  #     do (method) =>
  #       @::[method] = -> @model[method].apply(@model, arguments)

  # constructor: (@view, @model) ->
  #   @cid = @model.cid

  # binding: (field, options, fn) ->
  #   if _.isFunction(options)
  #     [fn, options] = [options, {}]

  #   new @constructor.bindables[field](@view, @model, field, options, fn)

  # input: (path, options) ->
  #   new AS.Binding.Input(@view, @model, path, options)

  # checkbox: (path, options) ->
  #   new AS.Binding.CheckBox(@view, @model, path, options)

  # select: (path, options) ->
  #   new AS.Binding.Select(@view, @model, path, options)

  # editline: (path, options) ->
  #   new AS.Binding.EditLine(@view, @model, path, options)

  # element: (tagname, fn) ->
  #   element = @context[tagname] class: @model.constructor.name, fn
  #   @view.$(element).data().model = @model
  #   element

  # component: (ctor) ->
  #   if component = @model.component(ctor)
  #     AS.ViewModel.build(@view, component)
  #   else
  #     null

