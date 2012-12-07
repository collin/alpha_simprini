{bind, flatten, each} = _
{upperCamelize} = fleck


class AS.LocalStorageController
  def initialize: (@target) ->
    @target.addEventListener "message", bind(@receiveMessage, this), false

  def receiveMessage: (message) ->
    return unless method = message.data.event?.match(/localStorage.(\w+)/)?[1]
    @[method].apply(@, message.data.args)

  def setItem: (key, value) ->
    console.log "[localStorage] setItem #{key} #{value}"
    localStorage.setItem key, value

  def getItem: (id, key) ->
    value = localStorage.getItem(key)
    console.log "[localStorage] getItem #{id} #{key} #{value}"
    @target.postMessage event: "localStorage.getItem.#{id}", value: value


class AS.PostMessageLocalStorage
  def initialize: (@source, @target) ->
    @receivers = {}
    @source.addEventListener "message", bind(@receiveMessage, this), false

  def setItem: (key, value) ->
    console.info "[localStorage] setItem #{key}, #{value}"
    id =  AS.uniq()
    @target.postMessage event:"localStorage.setItem", args: [key, value]

  def getItem: (key, callback) ->
    id =  AS.uniq()
    @receivers[id] = callback
    @target.postMessage event:"localStorage.getItem", args: [id, key]
    
  def receiveMessage: (message) ->
    return unless id = message.data.event?.match(/localStorage.getItem.(\w+)/)?[1]
    console.info "[localStorage] getItem #{message.data.value}"
    @receivers[id](message.data.value)
    @receivers[id] = undefined

class AS.PostMEssageLogger
  def initialize: (@source, @name="postMessage") ->
    @source.addEventListener "message", bind(@receiveMessage, this)

  def receiveMessage: (message) ->
    data = message.data
    if method = data.event?.match(/console.(\w+)/)?[1]
      console[method].apply(console, ["[#{@name}]", data.args...])
    else
      console.debug "message", data

class AS.PostMessageController
  include Taxi.Mixin

  def initialize: (@accept, @source={}, @commands={}) ->
    unless @source instanceof window.Worker
      [@commands, @source] = [@source, undefined]
    (@source || window).addEventListener "message", bind(@receiveMessage, this), false

  def receiveMessage: (event) ->
    return unless @accept in ["*", event.source, event.origin]
    [identifier, args...] = flatten event.data
    if command = @commands[identifier]
      return unless command.apply
      command.apply(null, [event].concat(args))
    else
      return if @commands.write is false
      console.log "receiveMessage#{upperCamelize identifier}"
      @["receiveMessage#{upperCamelize identifier}"]?.apply(this, [event].concat(args))    

    @trigger "message"
    Taxi.Governer.exit() if Taxi.Governer.currentLoop

  def receiveMessageCreate: (event, path, id, data) ->
    AS.loadPath(path).find(id).set(data)

  def receiveMessageDestroy: (event, id) ->
    AS.All.byId[id].destroy()

  def receiveMessageAdd: (event, id, field, itemId, options) ->
    AS.All.byId[id][field].add(itemId, options)

  def receiveMessageRemove: (event, id, field, itemId) ->
    AS.All.byId[id][field].remove(AS.Model.find itemId)

  def receiveMessageChange: (event, id, field, value) ->
    AS.All.byId[id][field].set(value)


class AS.PostMessageSource
  def initialize: (@target, @origin) ->
    @post = @["postTo#{@target.constructor.name}"]

  def postToWindow: (args) ->
    @target.postMessage args, @origin
  
  def postToWorker: (args) ->
    @target.postMessage args


class AS.Model.PostMessageAdapter
  include Taxi.Mixin

  delegate 'post', to: 'source'

  def initialize: ->
    @registrations = Pathology.Set.new()

  def connect: (event) -> 
    @source = AS.PostMessageSource.new(event.source, event.origin)
    @trigger("ready")

  def register: (model) ->
    return if @registrations.include(model)
    @registrations.add(model)
    console.log "[postmessage] register", model.toString(), model.id

    @binds model, "destroy", ->
      @unbind(model)
      @post ["destroy", model.id]
      @registrations.remove(model)

    each model.properties(), (property) =>
      if property.constructor is AS.Model.HasMany.Instance
        property.each bind(@register, this)

        @binds property, "add", (item, options) -> 
          @register(item)
          @post ["add", model.id, property.options.name, item.id, at:options.indexOf(item).value()]

        @binds property, "remove", (item) -> 
          @post ["remove", model.id, property.options.name, item.id]

      else
        if current = property.get()
          console.log "currentValue", current.toString()
          @register(current) if current?.model instanceof AS.Model

        @binds property, "change", -> 
          value = property.get()
          if value?.model instanceof AS.Model
            @register(value)
            value = value.id 
          @post ["change", model.id, property.options.name, value]

    @post ["create", model.model.constructor.path(), model.id, model.payload()]

    return model

  def binds: (model, event, handler) ->
    model.bind
      namespace: @objectId()
      event: event
      handler: handler
      context: this

  def reset: ->
    @registrations.each (model) => @unbind(model)
    PL.editor.postMessageAdapter.registrations.empty()

  def unbind: (model) ->
    model.unbind ".#{@objectId()}"
    for property in model.properties() 
      property.unbind ".#{@objectId()}"
    