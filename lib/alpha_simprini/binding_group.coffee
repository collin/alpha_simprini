AS = require("alpha_simprini")
class AS.BindingGroup

  constructor: ->
    @namespace = _.uniqueId(".bg")
    @initialize()
    
  initialize: ->
    @children = []
    @bound_objects = []
  
  # Unbind all bindings, and then unbind all children binding groups
  unbind: ->
    object.unbind(@namespace) for object in @bound_objects
    child.unbind() for child in @children
    @initialize()
    
  binds: (object, event, handler, context) -> 
    @bound_objects.push object
    object.bind event + @namespace, handler, context

  add_child: -> 
    child = new AS.BindingGroup
    @children.push child
    return child
  
  remove_child: (binding_group) -> @children = _(@children).without(binding_group)
