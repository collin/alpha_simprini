AS = require("alpha_simprini")
_ = require("underscore")

AS.Model.HasMany = AS.Model.Field.extend()
AS.Model.HasMany.Instance = AS.Model.Field.Instance.extend ({def, delegate}) ->
  delegate AS.COLLECTION_DELEGATES, to: "backingCollection"
  
  def initialize: (@object, @options={}) ->
    @options.source = @object if @options.inverse
    @backingCollection = AS.Collection.new(undefined, @options)

  def set: (models) ->
    @backingCollection.add models

  def add: (models) -> @backingCollection.add.apply(@backingCollection, arguments)

  def at: (models) -> @backingCollection.at.apply(@backingCollection, arguments)

  def remove: (models) -> @backingCollection.remove.apply(@backingCollection, arguments)

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
      @raw.at(@path).insert(options.at, id: model.id, _type: model.constructor.path())

    def remove: (model, options) ->
      @raw.at(@path, options.at).remove()

    def each: (fn) ->
      _.each @raw.at(@path).get(), fn

#FIXME: this should have worked
# AS.Model.HasMany.Instance.delegate "add", "remove", "bind", "unbind", "trigger", to: "backingCollection"

AS.Model.defs hasMany: (name, options) -> 
  AS.Model.HasMany.new(name, this, options)
