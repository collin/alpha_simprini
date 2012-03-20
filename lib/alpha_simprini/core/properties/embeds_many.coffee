AS = require "alpha_simprini"

AS.Model.EmbedsMany = AS.Model.HasMany.extend()
AS.Model.EmbedsMany.Instance = AS.Model.HasMany.Instance.extend ({def, delegate}) ->

AS.Model.defs embedsMany: (name, options) -> 
  AS.Model.EmbedsMany.new(name, this, options)
