AS.Model.BelongsTo = AS.Model.HasOne.extend ({delegate, include, def, defs}) ->
AS.Model.BelongsTo.Instance = AS.Model.HasOne.Instance.extend ({delegate, include, def, defs}) ->
  def bindToValue: (value) ->
    @_super.apply(this, arguments)
    value.bind "destroy#{@namespace}", =>
      if @options.dependant is "destroy"
        @object.destroy()
      else
        @set(null)

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
