AS = require("alpha_simprini")
_ = require "underscore"

AS.Binding = AS.Object.extend ({def}) ->
  def initialize: (@context, @model, @field, @options={}, @fn=undefined) ->
    @event = "change:#{field}"

    if _.isFunction(@options)
      [@fn, @options] = [@options, {}]

    @container = @context.$ @context.currentNode
    @bindingGroup = @context.bindingGroup

    @content = @context.$ []

    if @willGroupBindings()
      @context.groupBindings (bindingGroup) ->
        @bindingGroup = bindingGroup
      @setup()
    else
      @setup()

  def willGroupBindings: ->
    @constructor.willGroupBindings or _.isFunction(@fn)

  def fieldValue: -> @field.get()

  def require_option: (name) ->
    return unless @options[name] is undefined
    throw new AS.Binding.MissingOption("You must specify the #{name} option for #{@constructor.name} bindings.")

  def setup: ->

class AS.Binding.MissingOption extends Error

# class AS.Binding.EmbedsMany extends AS.Binding.HasMany
# class AS.Binding.EmbedsOne extends AS.Binding.Field
#   @willGroupBindings = true

# class AS.Binding.HasOne extends AS.Binding.Field
#   @willGroupBindings = true

# class AS.Binding.Collection extends AS.Binding.HasMany
#   fieldValue: -> @model

# # use case: RadioSelectionModel
# # ala-BAM-a
# # @element_focus.binding "selected", (element) ->
# #   new Author.Views.ElementBoxAS.Binding(this, @div class:"Focus", element)
# #
# # @element_selection.binding "selected", (element) ->
# #   new Author.Views.ElementBoxBinding(this, @div class:"Selection", element)

# class AS.Binding.BelongsTo extends AS.Binding
#   @willGroupBindings = true

#   initialize: ->
#     @makeContent()
#     @context.withinBindingGroup @bindingGroup, ->
#       @context.binds @model, @event, @changed, this

#   changed: ->
#     @content.remove()
#     @bindingGroup.unbind()
#     @initialize()

#   makeContent: ->
#     item = @fieldValue()
#     if item
#       @context.withinBindingGroup @bindingGroup, ->
#         @context.withinNode @container, ->
#           @content = @context.$ []
#           binding = new AS.Binding.Model(@context, item, @content)
#           made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
#           if made?.jquery
#             @content.push made[0]
#           else
#             @content.push made
#           binding.paint()
#           @content
#     else
#       @content = @context.$ []
