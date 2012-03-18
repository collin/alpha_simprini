AS = require("alpha_simprini")
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
      @set(@options.default) if @options.default

    def get: ->
      casters[@options.type.name].read(@value)

    def set: (value) ->
      writeValue = casters[@options.type.name].write(value)
      return if writeValue is @value
      @value = writeValue
      @object.trigger("change")
      @object.trigger("change:#{@options.name}")
      @trigger("change")
      value


AS.Model.defs field: (name, options) -> 
  AS.Model.Field.new(name, this, options)

