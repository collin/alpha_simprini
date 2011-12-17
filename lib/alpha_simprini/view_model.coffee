AS = require("alpha_simprini")

class AS.ViewModel
  AS.Delegate.extends(this)
  
  @build: (view, model) ->
    constructor = AS.ViewModel.constructor_for_model(model.constructor)
    new constructor(view, model)
  
  @constructor_for_model: (model) ->
    return AS.ViewModel[model.name] if AS.ViewModel[model.name]
    
    klass = class AS.ViewModel[model.name] extends AS.ViewModel
    klass.name = model.name
    klass::type = model.name
    
    klass.bindables = {}
    klass.extended_by = model.extended_by
    
    klass.field(field) for field, __ of model.fields if model.fields
    klass.has_many(has_many) for has_many, __ of model.has_manys if model.has_manys
    klass.has_one(has_one) for has_one, __ of model.has_ones if model.has_ones
    klass.belongs_to(belongs_to) for belongs_to, __ of model.belongs_tos if model.belongs_tos
    
    klass.delegations(model)
    
    klass
  
  @field: (name) -> 
    @::[name] = -> @model[name].apply(@model, arguments)
    @bindables[name] = AS.Binding.Field

  @has_many: (name) -> 
    @::[name] = -> @model[name].apply(@model, arguments)
    @bindables[name] = AS.Binding.HasMany
    
  @has_one: (name) -> 
    @::[name] = -> @model[name].apply(@model, arguments)
    @bindables[name] = AS.Binding.HasOne
  
  @belongs_to: (name) -> 
    @::[name] = -> @model[name].apply(@model, arguments)
    @bindables[name] = AS.Binding.BelongsTo
  
  @delegations: (model) ->
    for method in AS.instance_methods(model)
      do (method) =>
        @::[method] = -> @model[method].apply(@model, arguments)
  
  constructor: (@view, @model) ->
    @cid = @model.cid
  
  binding: (field, options, fn) ->
    if _.isFunction(options)
      [fn, options] = [options, {}]
      
    new @constructor.bindables[field](@view, @model, field, options, fn)
  
  input: (field, options) ->
    new AS.Binding.Input(@view, @model, field, options)
  
  editline: (field, options) ->
    new AS.Binding.EditLine(@view, @model, field, options)
  
  element: (tagname, fn) ->
    element = @context[tagname] class: @model.constructor.name, fn
    $(element).data().model = @model
    element
  
  component: (constructor) ->
    AS.ViewModel.build(@view, @model.component(constructor).value())
  