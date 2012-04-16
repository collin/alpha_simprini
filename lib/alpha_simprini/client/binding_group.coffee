AS = require("alpha_simprini")
_ = require "underscore"

AS.BindingGroup = AS.Object.extend ({def}) ->

  def initialize: ->
    @namespace = _.uniqueId("bg")
    @children = []
    @boundObjects = []

  # Unbind all bindings, and then unbind all children binding groups
  def unbind: ->
    object.unbind(@namespace) for object in @boundObjects
    child.unbind() for child in @children
    @initialize()

  def binds: (object, event, handler, context) ->
    @boundObjects.push object

    if object.jquery
      object.bind "#{event}.#{@namespace}", _.bind(handler, context)
    else if _.isArray(event)
      object.bindPath(event, _.bind(handler, context))
    else
      object.bind 
        event: event
        namespace: @namespace
        handler: handler
        context: context

  def addChild: (child=AS.BindingGroup.new())->
    @children.push child
    return child

  def removeChild: (bindingGroup) -> @children = _(@children).without(bindingGroup)
