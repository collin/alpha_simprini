AS = require("alpha_simprini")

AS.Model.VirtualProperty = AS.Property.extend ({def}) ->

AS.Model.VirtualProperty.Instance = AS.Property.Instance.extend ({def}) ->

AS.Model.defs virtualProperties: (dependencies..., properties) -> 
  for name, fn of properties
    AS.Model.VirtualProperty.new(name, this, dependencies: dependencies, fn: fn)
