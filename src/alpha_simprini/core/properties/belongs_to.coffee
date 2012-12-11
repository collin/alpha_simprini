class AS.Model.BelongsTo < AS.Model.HasOne
class AS.Model.BelongsTo.Instance < AS.Model.HasOne.Instance
  def bindToValue: (value) ->
    @_super.apply(this, arguments)
    value.bind "destroy#{@namespace}", =>
      if @options.dependant is "destroy"
        @object.destroy()
      else
        @set(null)

class AS.Model.BelongsTo.Instance.Synapse < AS.Model.Field.Instance.Synapse
  def get: ->
    @raw.get()

  def set: (value) ->
    @raw.set(value)

class AS.Model.BelongsTo.Instance.ShareSynapse < AS.Model.Field.Instance.ShareSynapse
  def get: ->
    @raw.at(@path).get()

  def set: (value) ->
    @_super(value?.id) if value?.id


AS.Model.defs belongsTo: (name, options) ->
  AS.Model.BelongsTo.new(name, this, options)
