AS = require "alpha_simprini"

AS.Model.BelongsTo = AS.Model.HasOne.extend()
AS.Model.BelongsTo.Instance = AS.Model.HasOne.Instance.extend ({def, delegate}) ->

AS.Model.defs belongsTo: (name, options) -> 
  AS.Model.BelongsTo.new(name, this, options)
