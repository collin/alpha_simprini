AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.BelongsTo = AS.Model.HasOne.extend()
AS.Model.BelongsTo.Instance = AS.Model.HasOne.Instance.extend ({delegate, include, def, defs}) ->
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
