AS = require "alpha_simprini"
_ = require "underscore"
ShareJs = require("share").client

AS.ShareJsURL = "http://#{window?.location.host or 'localhost'}/sjs"

AS.openSharedObject = (id, callback) ->
  ShareJs.open id, "json", @ShareJsURL, (error, handle) ->
    if error then console.log(error) else callback(handle)

AS.Model.Share = AS.Module.extend ({delegate, include, def, defs}) ->
  defs index: (name, config) ->
    @writeInheritableValue 'indeces', name, config


  defs shared: (id=AS.uniq(), indexer=(model) -> ) ->
    model = AS.All.byId[id] or @new(id:id)
    AS.openSharedObject id, (share) ->
      model.didOpen(share)
      indexer(model)
    model

  defs load: (model, callback= ->) ->
    AS.openSharedObject model.id, (share) ->
      callback.call(model)
      model.didLoad(share)
    model

  def new: ->
    @share is undefined
    
  def whenIndexed: (fn) ->
    if @hasIndexed
      fn.call(this)
    else
      (@whenIndexedCallbacks ?= []).push fn

  def didIndex: ->
    return if @hasIndexed
    @hasIndexed = true
    for fn in @whenIndexedCallbacks ? []
      fn.call(this)

  def didOpen: (@share) ->
    @share.at().set({}) if @share.at().get() in [null, undefined]
    @buildIndeces()
    @loadIndeces()

  def didLoad: (@share) ->
    @share.at().set({}) if @share.at().get() in [null, undefined]
    @buildIndeces()
    @loadIndeces()

  def didEmbed: (@share) ->
    if @share.at().get() in [null, undefined]
      @share.at().set({_type: @constructor.toString(), id:@id}) 
    @buildIndeces()
    @loadIndeces()

  def indeces: ->
    @index(name) for name, config of @constructor.indeces
    
  def buildIndeces: ->
    for index in @indeces()
      index.set({}) unless index.get()

  def properties: ->
    @[name] for name, config of @constructor.properties
    
  def bindShareEvents: ->
    for property in @properties()
      property?.syncWith?(@share)

    for index in @indeces()
      index.on "insert", (id, path) =>
        constructor = AS.loadPath(path)
        model = constructor.find(id)
        constructor.load model
        @trigger("indexload", model)

  def stopSync: ->
    property.stopSync?() for property in @properties()

  def index: (name) ->
    @share.at("index:#{name}")

  def indexer: (name) ->
    return (model) =>
      @index(name).at(model.id).set model.constructor.path(), (error) ->
        # AS.warn "FIXME: handle error in Model#indexer"
        model.didIndex()

  def loadIndeces: ->
    indeces = @indeces()
    loadedIndex = _.after indeces.length, _.bind(@indecesDidLoad, this)
    @loadIndex(index, loadedIndex) for index in indeces

  def loadIndex: (index, callback) ->
    specs = index.get()
    count = _(specs).keys().length
    loadedItem = _.after count, callback
    for id, _type of specs
      constructor = AS.loadPath(_type)
      model = constructor.find(id)

      model.bind "ready", -> loadedItem()
      model.bind "destroy", -> index.at(id).remove()

      model = constructor.load model, ->
        # @indecesDidLoad()
        
  def indecesDidLoad: ->
    @bindShareEvents()
    @didIndex()
    console.log "indecesDidLoad", @toString()
    @trigger("ready")
    
    
    

