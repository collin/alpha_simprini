class AS.Model.HasOne < AS.Model.Field
  def couldBe: (test) ->
    return true if test in @options.model?().ancestors
    @_super.apply(this, arguments)
  # @::couldBe.doc =
  #   params: [
  #     ["test", undefined, true]
  #   ]
  #   desc: """
  #
  #   """

class AS.Model.HasOne.Instance < AS.Model.Field.Instance
  def initialize: (@object, @options) ->
    @options.model ?= -> AS.Model
    @model = @options.model
    @namespace = ".#{_.uniqueId()}"
    @_super.apply(this, arguments)
    @bind "destroy", => @set(null)

    if @options.dependant is "destroy"
      @object.bind "destroy#{@namespace}", => @value?.destroy()
  # @::initialize.doc =
  #   params: [
  #     ["@object", AS.Model, true]
  #     ["@options", Object, true]
  #   ]
  #   desc: """
  #
  #   """

  def get: ->
    @value
  # @::get.doc =
  #   return: [AS.Model, null]
  #   desc: """
  #
  #   """

  def set: (value) ->
    value = value.model if value?.model
    return @value if value is @value

    if _.isString(value) and (konstructor = @model()) isnt AS.Model
      value = konstructor.find(value)
    else if _.isString(value)
      value = AS.All.byId[value]
    else if value instanceof AS.Model
      value = value
    else if _.isObject(value)
      value = @options.model().new(value)

    @value?.unbind(@namespace)

    # TODO: test inverse

    if @value and @options.inverse and @value[@options.inverse]
      @value[@options.inverse].remove(@object) if @value[@options.inverse].include(@object).value()

    @value = value

    if @value and @options.inverse and @value[@options.inverse]
      @value[@options.inverse].add(@object) unless @value[@options.inverse].include(@object).value()

    @bindToValue(@value) if @value

    @object.trigger("change")
    @object.trigger("change:#{@options.name}")
    @trigger("change")
    @triggerDependants()
    @value
  # @::set.doc =
  #   params: [
  #     ["value", AS.Model]
  #   ]
  #   desc: """
  #
  #   """

  def rawValue: -> @value?.id

  def bindToValue: (value) ->
    value.bind "change#{@namespace}", => @triggerDependants()
    value.bind "destroy#{@namespace}", => @set(null)
  
class AS.Model.HasOne.Instance.Synapse < AS.Model.Synapse
  def get: ->
    @raw.get()

  def set: (value) ->
    @raw.set(value)

class AS.Model.HasOne.Instance.Synapse < AS.Model.Field.Instance.ShareSynapse
  def get: ->
    @raw.at(@path).get()

  def set: (value) ->
    @_super(value?.id) if value?.id

AS.Model.defs hasOne: (name, options) ->
  AS.Model.HasOne.new(name, this, options)
