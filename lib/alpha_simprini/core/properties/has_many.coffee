AS = require("alpha_simprini")
_ = require("underscore")

AS.Model.HasMany = AS.Model.Field.extend ({delegate, include, def, defs}) ->
  def couldBe: (test) ->
    return true if @options.model?() in (test.ancestors or [])
    @_super.apply(this, arguments)

AS.Model.HasMany.Instance = AS.Model.Field.Instance.extend ({def, delegate}) ->
  delegate AS.COLLECTION_DELEGATES, to: "backingCollection"
  delegate 'groupBy', to: "backingCollection"
  
  def inspect: ->
    "#{@options.name}: [#{@backingCollection.length}]}"

  def initialize: (@object, @options={}) ->
    @model = @options.model
    @options.source = @object if @options.inverse
    @backingCollection = AS.Collection.new(undefined, @options)

    @bind('change', (=> @triggerDependants()), this)

  def syncWith: (share) ->
    console.log "syncWith", @toString()
    @share = share.at(@options.name)
    @stopSync()

    @synapse = @constructor.Synapse.new(this)
    @shareSynapse = @constructor.ShareSynapse.new(share, @options.name)

    alreadyThere = _.clone @backingCollection.models.value()

    @synapse.observe(@shareSynapse, field: @options.name)

    _.each alreadyThere, (item) => @shareSynapse.insert(item, {})

    @synapse.notify(@shareSynapse)

  def objects: ->
    @backingCollection.models.value()    

  def bindToPathSegment: (segment) ->
    segment.binds this, "add", segment.insertCallback
    segment.binds this, "remove", segment.removeCallback

  def set: (models) ->
    @backingCollection.add(model) for model in models

  def add: -> 
    added = @backingCollection.add.apply(@backingCollection, arguments)
    @triggerDependants()
    return added


  def at: (models) -> @backingCollection.at.apply(@backingCollection, arguments)

  def remove: -> 
    removed = @backingCollection.remove.apply(@backingCollection, arguments)
    @triggerDependants()
    return removed

  def bind: -> @backingCollection.bind.apply(@backingCollection, arguments)

  def trigger: -> @backingCollection.trigger.apply(@backingCollection, arguments)

  def unbind: -> @backingCollection.unbind.apply(@backingCollection, arguments)

  def pluck: (key) ->
    @map (item) -> item[key].get()

  def any: ->
    _.any @backingCollection

  @Synapse = AS.Model.CollectionSynapse.extend ({delegate, include, def, defs}) ->
    def insert: (item, options) ->
      @raw.add(item, options)

    def remove: (item, options) ->
      @raw.remove @raw.at(options.at)
      
    def binds: (insertCallback, removeCallback) ->
      @raw.bind "add#{@namespace}", (model, collection, options) ->
        insertCallback(model, options)

      @raw.bind "remove#{@namespace}", (model, collection, options) -> 
        removeCallback(model, options)

    def each: (fn) -> @raw.each(fn)

    def unbinds: ->
      @raw.unbind(@namespace)

  @ShareSynapse = AS.Model.CollectionSynapse.extend ({delegate, include, def, defs}) ->
    def initialize: (@raw, @path...) ->
      @_super.apply(this, arguments)
      @raw.at(@path).set([]) unless @raw.at(@path).get()

    def binds: (insertCallback, removeCallback) ->
      raw = @raw.at(@path)
      @listeners = [
        raw.on "insert", (position, data) -> insertCallback(data, at: position)
        raw.on "delete", (position, data) -> removeCallback(data, at: position)
      ]

    def unbinds: ->
      @raw.removeListener(listener) for listener in @listeners
      
    def insert: (model, options) ->
      options.at ?= @raw.at(@path).get().length
      @raw.at(@path).insert(options.at, id: model.id, _type: model.constructor.path())

    def remove: (model, options) ->
      @raw.at(@path, options.at).remove()

    def each: (fn) ->
      _.each @raw.at(@path).get(), fn

#FIXME: this should have worked
# AS.Model.HasMany.Instance.delegate "add", "remove", "bind", "unbind", "trigger", to: "backingCollection"

AS.Model.defs hasMany: (name, options) -> 
  AS.Model.HasMany.new(name, this, options)
