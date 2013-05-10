{keys,bind,defer,each,flatten,compact,after} = _

class AS.Model.Adapter
  include Taxi.Mixin
  
  def initialize: ->
    @registrations = Pathology.Set.new()

  def register: (model, data={}) ->
    return if @registrations.include(model)

    @registrations.add(model)

    @binds model, "destroy", ->
      @unbind(model)
      @registrations.remove(model)
      @trigger "destroy", model

    each model.properties(), (property) =>      
      if property.constructor is AS.Model.HasMany.Instance
        property.each (item) => @register(item)

        @binds property, "add", (item) =>
          @register(item, item.payload())
          @trigger("update") unless property.remote is false

      else
        if current = property.get()
          @register(current, current.payload()) if current instanceof AS.Model

        @binds property, "change", -> 
          value = property.get()
          @register(value, value.payload()) if value instanceof AS.Model
          @trigger("update") unless property.remote is false

    return

  def binds: (model, event, handler) ->
    model.bind
      namespace: @objectId()
      event: event
      handler: handler
      context: this

  def unbind: (model) ->
    namespace = ".#{@objectId()}"
    model.unbind namespace
    for property in model.properties() 
      property.unbind(namespace)

  def unbindAll: ->
    @registrations.each (model) => @unbind(model)
    @initialize()
    

  REFERENCES = [AS.Model.HasMany, AS.Model.HasOne, AS.Model.BelongsTo, AS.Model.VirtualProperty]

  def sideload: (objectspace) ->
    for constructorPath, objects of objectspace
      ctor = AS.loadPath(constructorPath)
      properties = []
      for name, property of ctor.properties
        continue if property.constructor in REFERENCES
        properties.push name

      for id, data of objects
        model = AS.All.byId[id] || ctor.prepare(id:id)
        for property in properties
          model[property].set(data[property]) if data[property]

  def resolveReferences: (objectspace) ->
    for constructorPath, objects of objectspace
      ctor = AS.loadPath(constructorPath)
      properties = []
      for name, property of ctor.properties
        continue unless property.constructor in REFERENCES
        properties.push name

      for id, data of objects
        model = AS.All.byId[id]
        for property in properties
          model[property].set(data[property]) if data[property]
