AS = require "alpha_simprini"

AS.Model.EmbedsOne = AS.Model.HasOne.extend()
AS.Model.EmbedsOne.Instance = AS.Model.HasOne.Instance.extend ({delegate, include, def, defs}) ->
  def syncWith: (share) ->
    @share = share.at(@options.name)
    @set @share.get() if @share.get()

  def set: (value) ->
    @value.stopSync() if @value
    @_super.apply(this, arguments)
    @value.didEmbed(@share) if @share# unless value in [@value, undefined, null]
    @value

AS.Model.defs embedsOne: (name, options) -> 
  AS.Model.EmbedsOne.new(name, this, options)
