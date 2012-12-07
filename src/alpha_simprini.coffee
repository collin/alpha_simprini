# Bootstraps
require "pathology"
require "taxi"
require "fleck"

module AlphaSimprini
window.AS = AlphaSimprini

require "alpha_simprini/core/string"
require "alpha_simprini/core/logging"


AS.unimplemented = (method) ->
  return ->
    throw new Error ["you MUST implement the method '#{method}' on: #{@toString()}"]

AS.part = (name) ->
  AS[name] = require: (libraries) -> AS.require name.toLowerCase(), libraries

# Namespaces
module AS.Models
module AS.Views


AS.Object = Pathology.Object
AS.Map = Pathology.Map
AS.Module = Pathology.Module
AS.Property = Taxi.Property
AS.Property.Instance.def rawValue: -> @value


AS.COLLECTION_DELEGATES = ["first", "rest", "last", "compact", "flatten", "without", "union", "filter", "reverse",
          "intersection", "difference", "uniq", "zip", "indexOf", "find", "detect", "sortBy",
          "lastIndexOf", "range", "include",  "each", "map", "reject","all", "toArray", "pluck", "invoke"]

AS.require = (framework="alpha_simprini", libraries) ->
  if libraries is undefined
    require "alpha_simprini/#{framework}"
  else
    for library in libraries.split(/\s+/)
      continue if library.match(/^\s+$/)
      require "alpha_simprini/#{framework}/#{library}"
  return

# Core libs, should run well in Node.js or in a Browser
require "alpha_simprini/core"
