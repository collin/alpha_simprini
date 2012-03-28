AS = require("alpha_simprini")
_ = require("underscore")
{isBoolean} = require "underscore"

casters =
  String:
    read: String
    write: String
  Number:
    read: Number
    write: Number
  Boolean:
    read: (value) ->
      return value if isBoolean(value)
      return true if value is "true"
      return false if value is "false"
      return false

    write: (value) ->
      return "true" if value is "true" or value is true
      return "false" if value is "false" or value is false
      return "false"

# TODO: Field is generic. reuse it.
AS.Model.Field = AS.Property.extend ({def}) ->
  def initialize: (@name, @_constructor, @options={}) ->
    @options.name = @name
    @_constructor.writeInheritableValue 'properties', @name, this

  def instance: (object) -> @constructor.Instance.new(object, @options)

  @Instance = AS.Property.Instance.extend ({def}) ->
    def initialize: (@object, @options={}) ->
      @options.type ?= String

    def syncWith: (share) ->
      synapse = @constructor.Synapse.new(this)
      shareSynapse = @constructor.ShareSynapse.new(share, @options.name)

      synapse.observe(shareSynapse, field: @options.name)
      synapse.notify(shareSynapse)

    def get: ->
      if @value isnt undefined
        value = casters[@options.type.name].read(@value)
      else
        @options.default

    def set: (value) ->
      writeValue = casters[@options.type.name].write(value)
      return if writeValue is @value
      @value = writeValue
      @object.trigger("change")
      @object.trigger("change:#{@options.name}")
      @trigger("change")
      value

    @Synapse = AS.Model.Synapse.extend ({delegate, include, def, defs}) ->
      delegate 'get', 'set', to: 'raw'

      def binds: (callback) ->
        @raw.bind "change", callback

      def unbind: (callback) ->
        @raw.unbind "change", callback

    @ShareSynapse = AS.Model.Synapse.extend ({delegate, include, def, defs}) ->

      def initialize: (@raw, @path...) ->
        @_super.apply(this, arguments)

      def get: ->
        @raw.at(@path).get()

      def set: (value) ->
        raw = @raw.at(@path)
        if _.isString(current = raw.get())
          length = current.length
          raw.del(0, length)
          raw.insert(0, value)
        else
          raw.set(value)          

      def binds: (callback) ->
        @listeners = [
          @raw.at().on("insert", callback)
          @raw.at().on("replace", callback)
          @raw.at(@path).on("insert", callback)
          @raw.at(@path).on("delete", callback)
        ]

      def unbind: (callback) ->
        @raw.removeListener(listener) for listener in @listeners
        @listeners = []




AS.Model.defs field: (name, options) -> 
  AS.Model.Field.new(name, this, options)

