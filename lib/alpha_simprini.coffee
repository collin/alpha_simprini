# this is where I used to require "bundle"

exports.Models = new Object
exports.Views = new Object

exports.require = (libraries) -> 
  for library in libraries.split(/\s+/)
    require "./alpha_simprini/#{library}"

exports.require """
  string
  logging
  
  mixin event callbacks inheritable_attrs delegate state_machine
  instance_methods
  
  collection model 
  
  dom view view_events view_model binding binding_group
  
  application

  models/radio_selection_model
    
  views/panel views/canvas views/region views/viewport
"""

 

# # ## Some little utility functions. 

exports.ConstructorIdentity = (constructor) -> (object) -> object.constructor is constructor
exports.Identity = (object) -> (other) -> object is other

exports.deep_clone = (it) ->
  if _.isArray(it)
    clone = _.clone(it)
  else if _.isObject(it)
    clone = {}
    for key, value of it
      if _.isArray(value) or _.isObject(value)
        clone[key] = exports.deep_clone(value)
      else
        clone[key] = value
  else
    clone = it
  
  clone
# `uniq` generates a probably unique identifier.
# large random numbers are base32 encoded and combined with the current time base32 encoded
exports.uniq = ->
  (Math.floor Math.random() * 100000000000000000).toString(32) + "-" + (Math.floor Math.random() * 100000000000000000).toString(32) + "-" + (new Date).getTime().toString(32)


exports.open_shared_object = (id, callback) ->
  console.log "opening shared object #{id}"
  sharejs.open id, "json", @sharejs_url, (error, handle) ->
    if error then console.error(error) else callback(handle)

exports.human_size = (size) ->
  units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  i = 0;
  while size >= 1024
    size /= 1024
    ++i

  size.toFixed(1) + ' ' + units[i]
