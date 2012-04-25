AS.Model.HasMany = AS.Model.Field.extend ({delegate, include, def, defs}) ->
  def couldBe: (test) ->
    return true if @options.model?() in (test.ancestors or [])
    @_super.apply(this, arguments)

AS.Model.HasMany.Instance = AS.Model.Field.Instance.extend ({def, delegate}) ->
  delegate AS.COLLECTION_DELEGATES, to: "backingCollection"
  delegate 'groupBy', 'bind', 'trigger', 'unbind', to: "backingCollection"

  def inspect: ->
    "#{@options.name}: [#{@backingCollection.length}]}"
  # @::inspect.doc =
  #   return: String
  #   desc: """
  #
  #   """

  def initialize: (@object, @options={}) ->
    @model = @options.model
    @options.source = @object if @options.inverse
    @backingCollection = AS.Collection.new(undefined, @options)

    @bind('change', (=> @triggerDependants()), this)
  # @::initialize.doc =
  #   params: [
  #     ["@object", AS.Model, true]
  #     ["@options", Obect, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def syncWith: (share) ->
    console.log "syncWith", @toString()
    @share = share.at(@options.name)
    @stopSync()

    @synapse = @constructor.Synapse.new(this)
    @shareSynapse = @constructor.ShareSynapse.new(share, @options.name)

    alreadyThere = _.clone @backingCollection.models.value()

    @synapse.observe(@shareSynapse)
    _.each alreadyThere, (item) => @shareSynapse.insert(item, {})
    @synapse.notify(@shareSynapse)
  # @::syncWith.doc =
  #   params: [
  #     ["share", "ShareJS.Doc", true]
  #   ]
  #   desc: """
  #
  #   """

  def objects: ->
    @backingCollection.models.value()
  # @::objects.doc =
  #   return: [AS.Model]
  #   desc: """
  #
  #   """

  def bindToPathSegment: (segment) ->
    segment.binds this, "add", segment.insertCallback
    segment.binds this, "remove", segment.removeCallback
  # @::bindToPathSegment.doc =
  #   params: [
  #     ["segment", Taxi.Segment, true]
  #   ]
  #   desc: """
  #
  #   """

  def set: (models) ->
    @backingCollection.add(model) for model in models
  # @::set.doc =
  #   params: [
  #     ["models", [[AS.Model, String, Object]], true]
  #   ]
  #   desc: """
  #
  #   """

  def add: (model, options) ->
    added = @backingCollection.add(model, options)
    @triggerDependants()
    return added
  # @::add.doc =
  #   params: [
  #     ["model", AS.Model, true]
  #     ["options", Object, false]
  #   ]
  #   desc: """
  #
  #   """

  def at: (index) -> @backingCollection.at.apply(@backingCollection, arguments)
  # @::at.doc =
  #   params: [
  #     ["index", Number, true]
  #   ]
  #   return: [AS.Model, undefined]
  #   desc: """
  #
  #   """

  def remove: (model) ->
    removed = @backingCollection.remove.apply(@backingCollection, arguments)
    @triggerDependants()
    return removed
  # @::remove.doc =
  #   params: [
  #     ["model", AS.Model, true]
  #   ]
  #   return: AS.Model
  #   desc: """
  #
  #   """

  def pluck: (key) ->
    @map (item) -> item[key].get()
  # @::pluc.doc =
  #   params: [
  #     ["key", String, true]
  #   ]
  #   return: ["*"]
  #   desc: """
  #
  #   """

  def any: ->
    _.any @backingCollection
  # @::any.doc =
  #   return: Boolean
  #   desc: """
  #
  #   """

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
      debugger if @path[0] is "compositions"
      options.at ?= @raw.at(@path).get().length
      @raw.at(@path).insert(options.at, model.id)

    def remove: (model, options) ->
      @raw.at(@path, options.at).remove()

    def each: (fn) ->
      _.each @raw.at(@path).get(), fn

#FIXME: this should have worked
# AS.Model.HasMany.Instance.delegate "add", "remove", "bind", "unbind", "trigger", to: "backingCollection"

AS.Model.defs hasMany: (name, options) ->
  AS.Model.HasMany.new(name, this, options)
