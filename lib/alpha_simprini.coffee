# Bootstraps
require "alpha_simprini/lib/alpha_simprini/string"
require "alpha_simprini/lib/core/logging"

# Namespaces
exports.Models = new Object
exports.Views = new Object

exports.require = (framework="alpha_simprini", libraries) -> 
  for library in libraries.split(/\s+/)
    continue if library.blank()
    require "alpha_simprini/lib/#{framework}/#{library}"

# Core libs, should run well in Node.js or in a Browser
require "alpha_simprini/core"

# this is where I used to require "bundle"
#   
#   
#   dom view view_events view_model binding binding_group
#   
#   application
# 
#   models/radio_selection_model
#     
#   views/panel views/canvas views/region views/viewport
# """

 

