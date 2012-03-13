# Bootstraps
Pathology = require "pathology"
Taxi = require "taxi"
require "./alpha_simprini/string"
require "./alpha_simprini/core/logging"

AS = module.exports = Pathology.Namespace.new("AlphaSimprini")

AS.part = (name) -> 
  exports[name] = require: (libraries) -> AS.require name.toLowerCase(), libraries

# Namespaces
AS.Models = Pathology.Namespace.new()
AS.Views = Pathology.Namespace.new()

AS.Object = Pathology.Object
AS.Module = Pathology.Module
AS.Namespace = Pathology.Namespace
AS.Property = Taxi.Property

AS.COLLECTION_DELEGATES = ["first", "rest", "last", "compact", "flatten", "without", "union", "filter", "reverse",
          "intersection", "difference", "uniq", "zip", "indexOf", "find", "detect",
          "lastIndexOf", "range", "include",  "each", "map", "reject","all", "toArray"]


AS.require = (framework="alpha_simprini", libraries) ->
  if libraries is undefined
    require "./alpha_simprini/#{framework}"
  else
    for library in libraries.split(/\s+/)
      continue if library.blank()
      require "./alpha_simprini/#{framework}/#{library}"

# Core libs, should run well in Node.js or in a Browser
require "./alpha_simprini/core"
