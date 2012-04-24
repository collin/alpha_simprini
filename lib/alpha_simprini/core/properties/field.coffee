AS = require("alpha_simprini")
_ = require("underscore")
{isBoolean, isString} = require "underscore"

# TODO: Field is generic. reuse it.

AS.Enum = AS.Object.extend ({delegate, include, def, defs}) ->
  defs read: (value, options) ->
    # AS.Assert options.values
    options.values[value]

  defs write: (value, options) ->
    # AS.Assert options.values
    options.values.indexOf(value)

AS.Model.Field = AS.Property.extend ({delegate, include, def, defs}) ->
  defs Casters: AS.Map.new()

  Casters = @Casters

  Casters.set String,
    read: (value) ->
      String(value) if value?

    write: (value) ->
      String(value) if value?

  Casters.set Number,
    read: (value) ->
      Number(value) if value?

    write: (value) ->
      String(value) if value?

  Casters.set Date,
    read: (value) ->
      if isString(value) then new Date(value) else value

    write: (value) ->
      if value instanceof Date then value.toJSON() else value

  Casters.set Boolean,
    read: (value) ->
      return value if isBoolean(value)
      return true if value is "true"
      return false if value is "false"
      return false

    write: (value) ->
      return "true" if value is "true" or value is true
      return "false" if value is "false" or value is false
      return "false"

  Casters.set AS.Enum, AS.Enum


  def initialize: (@name, @_constructor, @options={}) ->
    @options.name = @name
    @_constructor.writeInheritableValue 'properties', @name, this

  def instance: (object) -> @constructor.Instance.new(object, @options)

  @Instance = AS.Property.Instance.extend ({def}) ->
    def initialize: (@object, @options={}) ->
      @options.type ?= String

    def syncWith: (share) ->
      @share = share.at(@options.name)
      @share.set("") unless @share.get()?
      @stopSync()

      @synapse = @constructor.Synapse.new(this)
      @shareSynapse = @constructor.ShareSynapse.new(share, @options.name)

      @synapse.observe(@shareSynapse)
      @synapse.notify(@shareSynapse)

    def stopSync: ->
      @synapse?.stopObserving()
      @synapse?.stopNotifying()
      
    def get: ->
      if @value isnt undefined
        value = Casters.get(@options.type).read(@value, @options)
      else
        @options.default

    def set: (value) ->
      writeValue = Casters.get(@options.type).write(value, @options)
      return @value if writeValue is @value
      @value = writeValue
      @object.trigger("change")
      @object.trigger("change:#{@options.name}")
      @trigger("change")
      @triggerDependants()
      @value

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
        current = raw.get()
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
          @raw.at().on("insert", callback)
          @raw.at().on("replace", callback)
          @raw.at(@path).on("insert", callback)
          @raw.at(@path).on("delete", callback)
        ]

      def unbinds: (callback) ->
        @raw.removeListener(listener) for listener in @listeners
        @listeners = []




AS.Model.defs field: (name, options) -> 
  AS.Model.Field.new(name, this, options)

