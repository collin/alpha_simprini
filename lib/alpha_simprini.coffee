# Bootstraps
require "./alpha_simprini/string"
require "./alpha_simprini/core/logging"

exports.module = (string) ->
  parts = string.split(".")
  it = require _(parts.shift()).underscored()
  it = it[part] for part in parts    
  return it

exports.part = (name) -> 
  exports[name] = require: (libraries) -> exports.require name.toLowerCase(), libraries

# Namespaces
exports.Models = new Object
exports.Views = new Object

exports.require = (framework="alpha_simprini", libraries) ->
  if libraries is undefined
    require "./alpha_simprini/#{framework}"
  else
    for library in libraries.split(/\s+/)
      continue if library.blank()
      require "./alpha_simprini/#{framework}/#{library}"

# Core libs, should run well in Node.js or in a Browser
require "./alpha_simprini/core"
