AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.BelongsTo = AS.Model.Field.extend()
AS.Model.BelongsTo.Instance = AS.Model.Field.Instance.extend ({delegate, include, def, defs}) ->
  def initialize: ->
    @namespace = ".#{_.uniqueId()}"
    @_super.apply(this, arguments)
    @bind "destroy", => @set(null)
    
  def get: ->
    @value

  def set: (value) ->
    return if value is @value
    value = AS.All.byId[value] if _.isString(value)
    @value?.unbind(@namespace)
    @value = value
    @value?.bind "all#{@namespace}", _.bind(@trigger, this)
    @object.trigger("change")
    @object.trigger("change:#{@options.name}")
    @trigger("change")
    value

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
      

AS.Model.defs belongsTo: (name, options) -> 
  AS.Model.BelongsTo.new(name, this, options)
