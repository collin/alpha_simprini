AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.Share = AS.Module.extend ({delegate, include, def, defs}) ->
  defs index: (name, config) ->
    @writeInheritableValue 'indeces', name, config


  defs shared: (id=AS.uniq(), indexer=(model) -> model.didIndex()) ->
    model = AS.All.byId[id] or @new(id:id)
    AS.openSharedObject id, (share) ->
      model.didOpen(share)
      indexer(model)
    model

  defs load: (id, callback) ->
    unless model = AS.All.byId[id]
        model = AS.All.byId[id] or @new(id:id)
      callback ?= model.didLoad
      AS.openSharedObject id, _.bind(callback, model)
    model
    
  def initialize: ->
    @_super.apply(this, arguments)

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
    @bindShareEvents()
    @buildIndeces()

  def indeces: ->
    @index(name) for name, config of @constructor.indeces
    
  def buildIndeces: ->
    for index in @indeces()
      index.set({}) unless index.get()

  def properties: ->
    @[name] for name, config of @constructor.properties
    
  def bindShareEvents: ->
    property.syncWith?(@share) for property in @properties()
    for index in @indeces()
      index.on "insert", (id, konstructor) =>
        loaded = AS.loadPath(konstructor).load id, (share) ->
          @didLoad(share)
          @indecesDidLoad()
        @trigger("indexload", loaded)

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
      model = AS.loadPath(_type).load(id, loadedItem)
      model.bind "destroy", => 
        index.at(id).remove()
        
  def indecesDidLoad: ->
    unless @hasIndexed
      @bindShareEvents()
      @didIndex()
    # @build_loaded_data()
    # @set_attributes_from_share()

    # for name, config of @constructor.indeces
    #   for id, _type of @index(name).get()
    #     AS.All.byId[id].indeces_did_load()

    @trigger("ready")
    
    
    

