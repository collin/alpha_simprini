AS = require "alpha_simprini"

AS.Model.EmbedsOne = AS.Model.HasOne.extend()
AS.Model.EmbedsOne.Instance = AS.Model.HasOne.Instance.extend ({delegate, include, def, defs}) ->
  def syncWith: (share) ->
    @share = share.at(@options.name)

  def set: (value) ->
    @value.stopSync() if @value
    value.didEmbed(@share) unless value in [@value, undefined, null]
    @_super.apply(this, arguments)

AS.Model.defs embedsOne: (name, options) -> 
  AS.Model.EmbedsOne.new(name, this, options)
