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
AS.Model.Field = AS.Property.extend
  initialize: (@name, @_constructor, @options={}) ->
    @options.name = @name
    @_constructor.writeInheritableValue 'properties', @name, this

  instance: (object) -> @constructor.Instance.create(object, @options)

# TODO: Instance is specific
AS.Model.Field.Instance = AS.Model.Field.Instance.extend
  initialize: (@object, @options={}) ->
    @options.type ?= String
    @set(@options.default) if @options.default

  get: ->
    casters[@options.type.name].read(@value)

  set: (value) ->
    writeValue = casters[@options.type.name].write(value)
    return if writeValue is @value
    @value = writeValue
    @object.trigger("change")
    @object.trigger("change:#{@options.name}")
    @trigger("change")
    value


AS.Model.field = (name, options) -> 
  AS.Model.Field.create(name, this, options)

