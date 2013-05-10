class AS.ViewModel
  delegate 'readPath', 'writePath', to: 'model'

  defs build: (view, model) ->
    constructor = AS.ViewModel.constructorForModel(model.constructor)
    constructor.new(view, model)

  defs constructorForModel: (model) ->
    return AS.ViewModel[model.path()] if AS.ViewModel[model.path()]

    klass = AS.ViewModel[model.path()] = AS.ViewModel.extend()
    klass._meta0._name = model._name()
    klass._meta0._container = AS.ViewModel
    klass.name = model.name
    klass::type = model._name()

    klass.bindables = {}
    klass.extended_by = model.extended_by

    for name, property of model.properties
      klass.bindables[name] = switch property.constructor
        when AS.Model.Field, Pathology.Property, Taxi.Property, AS.Model.VirtualProperty
          AS.Binding.Field
        when AS.Model.BelongsTo, AS.Model.HasOne
          AS.Binding.One
        when AS.Model.HasMany
          AS.Binding.Many

    for method in AS.instanceMethods(model)
      continue if _.include _.keys(Pathology.Object::), method
      do (method) =>
        # FIXME: shouldn't be checking for specific conflicting methods here.
        if method is 'select'
          klass::[method] = -> @model[method].apply(@model, arguments)
        klass::[method] ?= -> @model[method].apply(@model, arguments)

    return klass

  def initialize: (@view, @model) ->
    @cid = @model.cid
    @id = @model.id
    @model.bind("change:id", (=> @id = @model.id))
    for key, config of @model.constructor.properties
      @[key] = @model[key]
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def toString: ->
    """<#{@constructor.path()}:#{@objectId()}
      view: #{@view.toString()}
      model: #{@model.toString()}
    >
    """
  def if: (field, branches) ->
    unless branches.then
      throw new Error("#{@toString()} 'if' binding must be given at least a 'then' function") 

    AS.Binding.If.new(@view, @model, @model[field], branches)

  def binding: (field, options, fn) ->
    if _.isFunction(options)
      [fn, options] = [options, {}]

    @constructor.bindables[field].new(@view, @model, @model[field], options, fn)
  # @::binding.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def unless: (field, branches) ->
    unless branches.then
      throw new Error("#{@toString()} 'unless' binding must be given at least a 'then' function")

    AS.Binding.Unless.new(@view, @model, @model[field], branches)

  def input: (field, options) ->
    AS.Binding.Input.new(@view, @model, field, options)
  # @::input.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def file: (field, options) ->
    AS.Binding.File.new(@view, @model, field, options)
  # @::file.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def checkbox: (field, options) ->
    AS.Binding.CheckBox.new(@view, @model, field, options)
  # @::checkbox.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def select: (field, options) ->
    AS.Binding.Select.new(@view, @model, field, options)
  # @::select.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def editline: (field, options) ->
    AS.Binding.EditLine.new(@view, @model, field, options)
  # @::editline.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def textarea: (field, options) ->
    AS.Binding.Textarea.new(@view, @model, field, options)
  # @::textarea.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

