AS = require("alpha_simprini")

AS.Model.HasOne = AS.Model.Field.extend()
AS.Model.HasOne.Instance = AS.Model.HasOne.Instance.extend
  initialize: (@object, @options) ->
    @options.model ?= -> AS.Model

  get: ->
    @value

  set: (object) ->
    return if object is @value
    object = object.model if object.model
    if object instanceof AS.Model
      @value = object
    else
      @value = @options.model().create(object)

    @object.trigger("change")
    @object.trigger("change:#{@options.name}")
    # @trigger("change")


  bind: -> @value.bind.apply(@value, arguments)

  trigger: -> @value.trigger.apply(@value, arguments)

  unbind: -> @value.unbind.apply(@value, arguments)

AS.Model.hasOne = (name, options) -> 
  AS.Model.HasOne.create(name, this, options)
