AS.Binding = AS.Object.extend ({def}) ->
  def initialize: (@context, @model, @field, @options={}, @fn=undefined) ->
    if _.isString(@field)
      @field = @model[@field]

    if _.isFunction(@options)
      [@fn, @options] = [@options, {}]

    @container ?= $ @context.currentNode
    @bindingGroup = @context.bindingGroup

    @content = @makeContent()

    if @willGroupBindings()
      @context.groupBindings (bindingGroup) =>
        @bindingGroup = bindingGroup

    @setup()
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def makeContent: ->
    @context.$ []
  # @::makeContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def willGroupBindings: ->
    @constructor.willGroupBindings or _.isFunction(@fn)
  # @::willGroupBindings.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def fieldValue: ->
    if _.isArray(@field)
      @model.readPath(@field)
    else
      @field.get()
  # @::fieldValue.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def requireOption: (name) ->
    return unless @options[name] is undefined
    throw new AS.Binding.MissingOption("You must specify the #{name} option for #{@constructor.name} bindings.")
  # @::requireOption.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def setup: ->
  # @::setup.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

class AS.Binding.MissingOption extends Error
