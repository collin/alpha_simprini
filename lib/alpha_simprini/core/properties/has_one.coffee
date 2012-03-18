AS = require("alpha_simprini")

AS.Model.HasOne = AS.Model.Field.extend()
AS.Model.HasOne.Instance = AS.Model.Field.Instance.extend ({def}) ->
  def initialize: (@object, @options) ->
    @options.model ?= -> AS.Model

  def get: ->
    @value

  def set: (object) ->
    return if object is @value
    object = object.model if object.model
    if object instanceof AS.Model
      @value = object
    else
      @value = @options.model().new(object)

    @object.trigger("change")
    @object.trigger("change:#{@options.name}")
    # @trigger("change")


  def bind: -> @value.bind.apply(@value, arguments)

  def trigger: -> @value.trigger.apply(@value, arguments)

  def unbind: -> @value.unbind.apply(@value, arguments)

AS.Model.defs hasOne: (name, options) -> 
  AS.Model.HasOne.new(name, this, options)
