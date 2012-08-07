# {bind, flatten, each} = _
# {upperCamelize} = fleck

# AS.Model.LocalStorageAdapter = AS.Object.extend ({delegate, include, def, defs}) ->
#   def localStorage: window.localStorage

#   delegate 'getItem', 'setItem', 'removeItem', to: 'localStorage'
    
#   def initialize: (@namespace) ->

#   def get: (key) ->
#     JSON.parse @getItem(@key key)

#   def set: (key, value) ->
#     JSON.parse @setItem(@key key)

#   def del: (key) ->
#     @removeItem(@key key)

#   def key: (key) ->
#     "#{@namespace}:#{key}"

# AS.Model.LocalStore = AS.Object.extend ({delegate, include, def, defs}) ->
#   delegate 'get', 'set', 'del', to: 'adapter'

#   def initialize: (rootModel, adapterClass=AS.Model.LocalStorageAdapter) ->
#     @adapter = adapterClass.new(rootModel.id)
#     @registrations = Pathology.Set.new()
#     @register(rootModel)

#   def register: ->

#   def register: (model) ->
#     return if @registrations.include(model)
#     @registrations.add(model)

#     @binds model, "destroy", ->
#       @unbind(model)
#       @del model.id
#       @registrations.remove(model)

#     each model.properties(), (property) =>
#       if property.constructor is AS.Model.HasMany.Instance
#         property.each bind(@register, this)

#         @binds property, "add", (item, options) -> 
#           @register(item)
#           @set 
#           @post ["add", model.id, property.options.name, item.id, at:options.indexOf(item).value()]

#         @binds property, "remove", (item) -> 
#           @post ["remove", model.id, property.options.name, item.id]

#       else
#         if current = property.get()
#           console.log "currentValue", current.toString()
#           @register(current) if current instanceof AS.Model

#         @binds property, "change", -> 
#           value = property.get()
#           if value instanceof AS.Model
#             @register(value)
#             value = value.id 
#           @post ["change", model.id, property.options.name, value]

#     @post ["create", model.constructor.path(), model.id, model.payload()]

#     return model

#   def binds: (model, event, handler) ->
#     model.bind
#       namespace: @objectId()
#       event: event
#       handler: handler
#       context: this

#   def reset: ->
#     @registrations.each (model) => @unbind(model)
#     PL.editor.postMessageAdapter.registrations.empty()

#   def unbind: (model) ->
#     model.unbind ".#{@objectId()}"
#     for property in model.properties() 
#       property.unbind ".#{@objectId()}"
 
    
