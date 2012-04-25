AS.BindingGroup = AS.Object.extend ({def}) ->

  def initialize: (@parentGroup) ->
    @namespace = _.uniqueId("bg")
    @children = []
    @boundObjects = []

  # Unbind all bindings, and then unbind all children binding groups
  def unbind: ->
    object.unbind("."+@namespace) for object in @boundObjects
    @unbindChildren()

  def unbindChildren: ->
    child.unbind() for child in @children
    @children = []

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

  def addChild: (child=AS.BindingGroup.new(this))->
    @children.push child
    return child

  def removeChild: (bindingGroup) -> @children = _(@children).without(bindingGroup)
