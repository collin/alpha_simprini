AS = require "alpha_simprini"

AS.Model.EmbedsOne = AS.Model.HasOne.extend()
AS.Model.EmbedsOne.Instance = AS.Model.HasOne.Instance.extend ({def, delegate}) ->

AS.Model.defs embedsOne: (name, options) -> 
  AS.Model.EmbedsOne.new(name, this, options)
