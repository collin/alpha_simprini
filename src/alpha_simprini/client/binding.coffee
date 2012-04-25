AS.Binding = AS.Object.extend ({def}) ->
  def initialize: (@context, @model, @field, @options={}, @fn=undefined) ->
    if _.isString(@field)
      @field = @model[@field]

    if _.isFunction(@options)
      [@fn, @options] = [@options, {}]

    @container ?= @context.$ @context.currentNode
    @bindingGroup = @context.bindingGroup

    @content = @makeContent()

    if @willGroupBindings()
      @context.groupBindings (bindingGroup) =>
        @bindingGroup = bindingGroup

    @setup()

  def makeContent: ->
    @context.$ []

  def willGroupBindings: ->
    @constructor.willGroupBindings or _.isFunction(@fn)

  def fieldValue: ->
    if _.isArray(@field)
      @model.readPath(@field)
    else
      @field.get()

  def require_option: (name) ->
    return unless @options[name] is undefined
    throw new AS.Binding.MissingOption("You must specify the #{name} option for #{@constructor.name} bindings.")

  def setup: ->

class AS.Binding.MissingOption extends Error
