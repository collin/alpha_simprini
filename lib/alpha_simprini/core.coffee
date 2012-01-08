AS = require "alpha_simprini"
Core = AS.part("Core")
_ = require "underscore"

Core.require """
  mixin event inheritable_attrs callbacks delegate state_machine
  instance_methods
  
  model collection model/share
  
  models/radio_selection_model
"""

AS.sharejs_url = "http://#{window?.location.host or 'localhost'}/sjs"

AS.share = require("share").client

# # ## Some little utility functions. 

AS.ConstructorIdentity = (constructor) -> (object) -> object.constructor is constructor
AS.Identity = (object) -> (other) -> object is other

AS.deep_clone = (it) ->
  if _.isFunction(it)
    clone = it
  else if _.isArray(it)
    clone = _.clone(it)
  else if _.isObject(it)
    clone = {}
    for key, value of it
      if _.isArray(value) or _.isObject(value)
        clone[key] = AS.deep_clone(value)
      else
        clone[key] = value
  else
    clone = it
  
  clone
# `uniq` generates a probably unique identifier.
# large random numbers are base32 encoded and combined with the current time base32 encoded
AS.uniq = ->
  (Math.floor Math.random() * 100000000000000000).toString(32) + "-" + (Math.floor Math.random() * 100000000000000000).toString(32) + "-" + (new Date).getTime().toString(32)


AS.open_shared_object = (id, callback) ->
  @share.open id, "json", @sharejs_url, (error, handle) ->
    if error then console.log(error) else callback(handle)

AS.human_size = (size) ->
  units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  i = 0;
  while size >= 1024
    size /= 1024
    ++i

  size.toFixed(1) + ' ' + units[i]
