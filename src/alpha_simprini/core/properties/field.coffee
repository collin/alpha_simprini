{isBoolean, isString} = _

# TODO: Field is generic. reuse it.

AS.Model.Enum = AS.Object.extend ({delegate, include, def, defs}) ->
  defs read: (value, options) ->
    # AS.Assert options.values
    options.values[value]

  defs write: (value, options) ->
    # AS.Assert options.values
    options.values.indexOf(value)

AS.Model.String = AS.Object.extend ({delegate, include, def, defs}) ->
  defs read: (value) ->
    String(value) if value?

  defs write: (value) ->
    String(value) if value?

AS.Model.Number = AS.Object.extend ({delegate, include, def, defs}) ->
  defs read: (value) ->
    Number(value) if value?

  defs write: (value) ->
    String(value) if value?

AS.Model.Date = AS.Object.extend ({delegate, include, def, defs}) ->
  defs read: (value) ->
    if isString(value) then new Date(value) else value

  defs write: (value) ->
    if value instanceof Date then value.toJSON() else value

AS.Model.Boolean = AS.Object.extend ({delegate, include, def, defs}) ->
  defs read: (value) ->
    return value if isBoolean(value)
    return true if value is "true"
    return false if value is "false"
    return false

  defs write: (value) ->
    return "true" if value is "true" or value is true
    return "false" if value is "false" or value is false
    return "false"

AS.Model.TokenList = AS.Object.extend ({delegate, include, def, defs}) ->
  defs read: (value) ->
    value.split(",")
  
  defs write: (value) ->
    value.join(",")
    

AS.Model.Field = AS.Property.extend ({delegate, include, def, defs}) ->
  defs Casters: AS.Map.new()

  Casters = @Casters

  Casters.set AS.Model.String, AS.Model.String

  Casters.set AS.Model.Number, AS.Model.Number

  Casters.set AS.Model.Date, AS.Model.Date

  Casters.set AS.Model.Boolean, AS.Model.Boolean

  Casters.set AS.Model.Enum, AS.Model.Enum


  def initialize: (@name, @_constructor, @options={}) ->
    @options.name = @name
    @options.type ?= AS.Model.String
    @_constructor.writeInheritableValue 'properties', @name, this
  # @::initialize.doc =
  #   params: [
  #     ["@name", String, true]
  #     ["@_constructor", AS.Model, true]
  #     ["@options", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def instance: (object) -> @constructor.Instance.new(object, @options)
  # @::instance.doc =
  #   params: [
  #     ["object", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  @Instance = AS.Property.Instance.extend ({def}) ->
    def initialize: (@object, @options={}) ->
      @options.type ?= AS.Model.String
    # @::initialize.doc =
    #   params: [
    #     ["@object", AS.Model, true]
    #     ["@options", Object, false, default: true]
    #   ]
    #   desc: """
    #
    #   """

    def syncWith: (share) ->
      @share = share.at(@options.name)
      @set shareValue if shareValue = @share.get()
      # #PERF console.time("set")
      # @share.set("") unless @share.get()?
      # #PERF console.timeEnd("set")
      @stopSync()

      @synapse = @constructor.Synapse.new(this)
      @shareSynapse = @constructor.ShareSynapse.new(share, @options.name)

      @synapse.notify(@shareSynapse)
    # @::syncWith.doc =
    #   params: [
    #     ["share", "ShareJS.Doc", true]
    #   ]
    #   desc: """
    #
    #   """

    def stopSync: ->
      # @synapse?.stopObserving()
      @synapse?.stopNotifying()
    # @::stopSync.doc =
    #   desc: """
    #
    #   """

    def get: ->
      if @value isnt undefined
        value = Casters.get(@options.type).read(@value, @options)
      else
        @options.default
    # @::get.doc =
    #   return: "*"
    #   desc: """
    #
    #   """

    def set: (value) ->
      writeValue = Casters.get(@options.type).write(value, @options)
      return @value if writeValue is @value
      @value = writeValue
      @object.trigger("change")
      @object.trigger("change:#{@options.name}")
      @trigger("change")
      @triggerDependants()
      @value
    # @::set.doc =
    #   params: [
    #     ["value", "*", true]
    #   ]
    #   desc: """
    #
    #   """

    @Synapse = AS.Model.Synapse.extend ({delegate, include, def, defs}) ->
      delegate 'get', 'set', to: 'raw'

      def binds: (callback) ->
        @raw.bind "change", callback

      def unbinds: (callback) ->
        @raw.unbind "change", callback

    @ShareSynapse = AS.Model.Synapse.extend ({delegate, include, def, defs}) ->

      def initialize: (@raw, @path...) ->
        @_super.apply(this, arguments)

      def get: ->
        @raw.at(@path).get()

      def set: (value) ->
        raw = @raw.at(@path)
        raw.set("") if ( current = raw.get() ) is undefined

        return if current is value
        if current
          length = current.length
          raw.del(0, length)
          raw.insert(0, value.toString())
        else if value
          raw.insert(0, value.toString())
        else if current
          raw.del(0, current.toString().length)

      def binds: (callback) ->
        @listeners = [
          # @raw.at().on("insert", callback)
          # @raw.at().on("replace", callback)
          # @raw.at(@path).on("insert", callback)
          # @raw.at(@path).on("delete", callback)
        ]

      def unbinds: (callback) ->
        @raw.removeListener(listener) for listener in @listeners
        @listeners = []




AS.Model.defs field: (name, options) ->
  AS.Model.Field.new(name, this, options)

