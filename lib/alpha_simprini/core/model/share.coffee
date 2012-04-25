AS = require "alpha_simprini"
_ = require "underscore"
{keys} = _
ShareJS = require("share").client

AS.ShareJSURL = "http://#{window?.location.host or 'localhost'}/sjs"

AS.Model.ShareJSAdapter = AS.Object.extend ({delegate, include, def, defs}) ->
  INDEX = "index"

  # delegate "adapterFor", to: "store"

  def initialize: ({@store, @url, @model, @share}) ->
    @model.adapter = this
    @url ?= AS.ShareJSURL


  def open: () ->
    ShareJS.open @model.id, "json", @url, (error, share) =>
      if error
        @store.trigger("share:open:error", error, this)
      else
        share.set(new Object) if share.get() is null
        @didOpen(share)

  def sync: (data={}) ->
    for property in @model.properties()
      property.syncWith?(@model.share, data[property.options.name])

  # when all indexed data is loaded, "ready" event is triggered on @model
  def didOpen: (@share) ->
    path = @model.constructor.path()

    constructorGroup = @constructorGroup(path)
    modelDocument = @modelDocument(constructorGroup)

    @loadEmbeddedData()
    @model.trigger("ready")

  def didLoad: (@share) ->
    path = @model.constructor.path()

    constructorGroup = @constructorGroup(path)
    modelDocument = @modelDocument(constructorGroup)

    @model.share = modelDocument
    @sync()
    @model.trigger("ready")

  def modelDocument: (constructorGroup) ->
    modelDocument = constructorGroup.at(@model.id)
    modelDocument.set(new Object) unless modelDocument.get()
    modelDocument
    
  def constructorGroup: (path) ->
    constructorGroup = @share.at(path)
    constructorGroup.set(new Object) unless constructorGroup.get()
    constructorGroup

  def eachEmbed: (fn) ->
    for key, value of @share.get()
      continue if key is INDEX
      fn.call(this, key, value)

  def loadEmbeddedData: ->
    # @share.at().on "insert", -> console.log "INSERT"
    # @share.at().on "replace", -> console.log "REPLACE"

    # First Pass creates objects
    @eachEmbed (path, data) ->
      @share.at(path).set(new Object) unless @share.at(path).get()
      constructor = AS.loadPath(path)
      for id, datum of data
        share = @share.at(path, id)
        model = constructor.find(id)
        model.share = share

    # Second Pass associates objects
    @eachEmbed (path, data) ->
      constructor = AS.loadPath(path)
      for id, datum of data
        model = constructor.find(id)

        if model is @model
          @sync()      
        else
          @adapterFor({model, @share}).sync()

        # model.set(datum)

  def adapterFor: (options) ->
    @store.adapterFor(options)
            

  # def loadIndexedData: ->
  #   selfReady = => @model.trigger("ready")

  #   index = @share.at(INDEX).get() or {}
  #   loadedIndex = _.after keys(index).length, selfReady

  #   for id, path of index
  #     constructor = AS.loadPath(path)
  #     model = constructor.find(id)
  #     model.bind "ready", loadedIndex
  #     @adapterFor({model}).open()
