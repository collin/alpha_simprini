{keys,bind,defer,each,flatten,compact,after} = _
require("bcsocket")
require("sharejs")
require("sharejs.json")
window.ShareJS = sharejs

AS.ShareJSURL = "http://#{window?.location.host or 'localhost'}/channel"

connections = {}

getConnection = (origin) ->  
  unless connections[origin]
    c = new ShareJS.Connection origin

    del = -> delete connections[origin]
    c.on 'disconnecting', del
    c.on 'connect failed', del
    connections[origin] = c
  
  connections[origin]


class AS.Models.ShareJSAdapter
  include Taxi.Mixin
  # delegate 'open', to: 'store'

  def initialize: (@url, documentName, @localStorage=window.localStorage) ->
    @documentName = documentName.toString()
    @registrations = Pathology.Set.new()
    @url ?= AS.ShareJSURL

    # Create the ShareJS document/connection
    @connection = getConnection(@url)
    @document = new ShareJS.Doc(@connection, @documentName, type: 'json', create: true)
    @connection.docs[@documentName] = @document

    # fetch the doc from localStorage if it's there.
    @fetchDoc =>
      # And whenever the document changes stash it in localStorage
      @document.on "change", bind(@stashDoc, this)
      # And whenever an op as acknowledged, update the stash
      @document.on "acknowledge", bind(@stashDoc, this)

      # Finally, open the document
      @open()


  def fetchDoc: (callback) ->
    didFetch = after 3, =>
      console.log "didFetch!"
      @loadEmbeddedData()
      callback()

    @localStorage.getItem "#{@documentName}:share:pendingOp", (value) =>
      @document.pendingOp = JSON.parse value
      didFetch()
      
    @localStorage.getItem "#{@documentName}:share:snapshot", (value) =>
      @document.snapshot = JSON.parse value
      didFetch()
      
    @localStorage.getItem "#{@documentName}:share:version", (value) =>
      @document.version = parseInt(value, 10)
      didFetch()
        
  def stashDoc: (op, snapshot) ->
    pendingOp = flatten compact [@document.inflightOp, @document.pendingOp]
    @localStorage.setItem "#{@documentName}:share:version", @document.version
    @localStorage.setItem "#{@documentName}:share:pendingOp", JSON.stringify(pendingOp)
    @localStorage.setItem "#{@documentName}:share:snapshot", JSON.stringify(@document.snapshot)

  def maybeClose: ->
    numDocs = 0
    for name, doc of @connection.docs
      numDocs++ if doc.state isnt 'closed' || doc.autoOpen

    @connection.disconnect() if numDocs == 0

  def open: ->
    @document.open (error) =>
      if error
        @maybeClose()
        @trigger("share:open:error", error, this)
      else
        @document.set(new Object) if @document.get() is null
        @didOpen()

  def didOpen: () ->
    @loadEmbeddedData()
    @bindRemoteOperationHandler()
    @trigger("ready")

  def eachEmbed: (fn) ->
    fn.call(this, key, value) for key, value of @document.get()

  def loadEmbeddedData: ->
    # @document.at().on "insert", -> console.log "INSERT"
    # @document.at().on "replace", -> console.log "REPLACE"

    # First Pass creates objects
    @eachEmbed (path, data) ->
      @document.at(path).set(new Object) unless @document.at(path).get()
      constructor = AS.loadPath(path)
      for id, datum of data
        # skipCallbacks, we'll call afterInitialize manually after the second pass
        constructor.find(id, skipCallbacks:true)

    # Second Pass associates objects
    @eachEmbed (path, data) ->
      constructor = AS.loadPath(path)
      for id, datum of data
        model = constructor.find(id)
        @register(model, datum)

    # Third Pass initializes objects
    @eachEmbed (path, data) ->
      constructor = AS.loadPath(path)
      for id, datum of data
        constructor.find(id).runCallbacks "afterInitialize"

    # Get out of the runLoop so the display will paint.
    Taxi.Governer.exit() if Taxi.Governer.currentLoop


    # # Third Pass trigers "ready" event
    # @eachEmbed (path, data) ->
    #   constructor = AS.loadPath(path)
    #   for id, datum of data
    #     model = constructor.find(id)
    #     model.trigger("share:ready")
    
  def modelDocument: (model) ->
    @constructorGroup(model.constructor).at(model.id)

  def constructorGroup: (constructor) ->
    constructorGroup = @document.at(constructor.path())
    constructorGroup.set(new Object) unless constructorGroup.get()
    constructorGroup

  def register: (model, data={}) ->
    return if @registrations.include(model)
    if @connection.state isnt "ok"
      console.log "will register model when connection 'ok'"
      @connection.on "ok", => @register(model, data)
      return model

    @registrations.add(model)
    console.log "[share] register", model.toString(), model.id

    model.share = @modelDocument(model)
    model.share.set(new Object) unless model.share.get()

    @binds model, "destroy", ->
      @unbind(model)
      @registrations.remove(model)

    each model.properties(), (property) =>
      return unless property.syncWith
      
      property.syncWith(model.share, data[property.options.name])

      if property.constructor is AS.Model.HasMany.Instance
        property.each (item) => @register(item)

        @binds property, "add", (item) =>
          @register(item, item.payload())

      else
        if current = property.get()
          console.log "currentValue", current.toString()
          @register(current, current.payload()) if current instanceof AS.Model

        @binds property, "change", -> 
          value = property.get()
          @register(value, value.payload()) if value instanceof AS.Model

    return

  def bindRemoteOperationHandler: ->
    @document.on "remoteop", bind(@remoteOperationHandler, this)

  NUMBER_ADD = "na"
  STRING_INSERT = "si"
  STRING_DELETE = "sd"
  LIST_INSERT = "li"
  LIST_DELETE = "ld"
  LIST_MOVE = "lm"
  OBJECT_INSERT = "oi"
  OBJECT_DELETE = "od"

  def remoteOperationHandler: (operation) ->
    for change in operation
      console.log "remoteop change", change

      path = change.p
      if path.length is 1
        @remoteClassOperation(change, path)
      else if path.length is 2
        @remoteInstanceOperation(change, path)
      else
        @remotePropertyOperation(change, path)

  def remoteClassOperation: (change, path) ->
    # Added a class to the document
    constructor = AS.loadPath(path[0])

    if change[OBJECT_INSERT]?
      objects = @document.at(path[0..1]).get()
      for id, object in objects
        @register constructor.find(id), object

    # Removed a class from the document
    # else if change[OBJECT_DELETE]      
    # don't think we should do much here

  def remoteInstanceOperation: (change, path) ->
    constructor = AS.loadPath(path[0])
    id = path[1]
    # Added an instance to the document
    if change[OBJECT_INSERT]?
      object = @document.at(path[0..1]).get()
      @register constructor.find(id), object

    # Deleted an instance from the document
    else if change[OBJECT_DELETE]?
      constructor.find(id).destroy()

  def remotePropertyOperation: (change, path) ->
    constructorPath = path[0]
    constructor = AS.loadPath(constructorPath)
    recordId = path[1]
    propertyName = path[2]

    record = constructor.find(recordId)
    property = record[propertyName]

    property.shareSynapse.block =>
      if change[NUMBER_ADD]?
        @log -> ["remote number add"]

      else if change[STRING_INSERT]?
        value = @document.at(path[0..2]).get()
        property.synapse.set value
        @log -> ["remote string insert", property, path[0..2], value]

      else if change[STRING_DELETE]?
        value = @document.at(path[0..2]).get()
        property.synapse.set value
        @log -> ["remote string delete", property, path[0..2], value]

      else if change[LIST_INSERT]? and change[LIST_DELETE]? # LIST REPLACE
        @log -> ["remote list replace"]

      else if change[LIST_INSERT]?
        property.synapse.insert change.li, at: path[3]
        @log -> ["remote list insert", property, change.li, path[3]]

      else if change[LIST_DELETE]?
        property.synapse.remove AS.All.byId[change.ld], at: path[3]
        @log -> ["remote list delete", property, change.li, path[3]]

      else if change[LIST_MOVE]?
        @log -> ["remote list move"]

      else if change[OBJECT_INSERT]? and change[OBJECT_DELETE]? # OBJECT REPLACE
        property.synapse.set value
        @log -> ["remote object replace", property, value, path[0..3]]

      else if change[OBJECT_INSERT]?
        value = @document.at(path[0..3]).get()
        property.synapse.set value
        @log -> ["remote object insert", property, value, path[0..3]]

      else if change[OBJECT_DELETE]?
        property.synapse.set null
        @log -> ["remote object delete", property, value, path[0..3]]

      # FIXME: don't break the runloop here.
      #         breaking runloop here ensures 
      #         property.shareSynapse.block takes
      #         effect.
      Taxi.Governer.exit() if Taxi.Governer.currentLoop

  def log: (fn) ->
    [event, data...] = fn()
    console.log "[#{event}] #{data.join(',')}"
    
# TODO: DRY this up. see PostMessageAdapter
  def binds: (model, event, handler) ->
    model.bind
      namespace: @objectId()
      event: event
      handler: handler
      context: this

  def unbind: (model) ->
    model.unbind ".#{@objectId()}"
    for property in model.properties() 
      property.unbind ".#{@objectId()}"
