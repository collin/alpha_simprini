AS.BindingGroup = AS.Object.extend ({def}) ->

  def initialize: (@parentGroup) ->
    @namespace = _.uniqueId("bg")
    @children = []
    @boundObjects = []
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  # Unbind all bindings, and then unbind all children binding groups
  def unbind: ->
    object.unbind("."+@namespace) for object in @boundObjects
    @unbindChildren()
  # @::unbind.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def unbindChildren: ->
    for child in @children
      # target view children for removal from their parent
      # if child instanceof AS.View

      # else
      child.unbind()
    @children = []
  # @::unbindChildren.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

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
  # @::binds.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def addChild: (child=AS.BindingGroup.new(this))->
    @children.push child
    return child
  # @::addChild.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def removeChild: (bindingGroup) -> @children = _(@children).without(bindingGroup)
  # @::removeChild.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
