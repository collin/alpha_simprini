AS = require("alpha_simprini")
_ = require("underscore")

AS.Model.HasOne = AS.Model.Field.extend ({delegate, include, def, defs}) ->
  def couldBe: (test) ->
    return true if test in @options.model?().ancestors
    @_super.apply(this, arguments)

AS.Model.HasOne.Instance = AS.Model.Field.Instance.extend ({def}) ->
  def initialize: (@object, @options) ->
    @options.model ?= -> AS.Model
    @model = @options.model
    @namespace = ".#{_.uniqueId()}"
    @_super.apply(this, arguments)
    @bind "destroy", => @set(null)

  def get: ->
    @value

  def set: (value) ->
    value = value.model if value?.model
    return @value if value is @value

    if _.isString(value)
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
      debugger if window.DEBUG
      @value[@options.inverse].add(@object) unless @value[@options.inverse].include(@object).value()
    
    @value?.bind "all#{@namespace}", _.bind(@trigger, this)
    @object.trigger("change")
    @object.trigger("change:#{@options.name}")
    @trigger("change")
    @value

  @Synapse = AS.Model.Field.Instance.Synapse.extend ({delegate, include, def, defs}) ->
    def get: ->
      @raw.get()

    def set: (value) ->
      @raw.set(value)
      
  @ShareSynapse = AS.Model.Field.Instance.ShareSynapse.extend ({delegate, include, def, defs}) ->
    def get: ->
      @raw.at(@path).get()
      
    def set: (value) ->
      @_super(value?.id) if value?.id

AS.Model.defs hasOne: (name, options) -> 
  AS.Model.HasOne.new(name, this, options)
