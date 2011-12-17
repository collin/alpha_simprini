# Bootstraps
require "alpha_simprini/lib/alpha_simprini/string"
require "alpha_simprini/lib/core/logging"

exports.part = (name) -> 
  exports[name] = require: (libraries) -> AS.require name.toLowerCase(), libraries

# Namespaces
exports.Models = new Object
exports.Views = new Object

exports.require = (framework="alpha_simprini", libraries) -> 
  for library in libraries.split(/\s+/)
    continue if library.blank()
    require "alpha_simprini/lib/#{framework}/#{library}"

# Core libs, should run well in Node.js or in a Browser
require "alpha_simprini/core"
