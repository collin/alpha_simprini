require "alpha_simprini"
Core = AS.part("Core")
require "underscore"

Core.require """
  logging

  callbacks state_machine
  instance_methods

  model model/dendrite model/synapse model/store
  properties/field properties/has_many properties/has_one
  properties/belongs_to properties/virtual_property

  collection filtered_collection

  models/radio_selection_model models/multiple_selection_model
  models/group models/grouping models/file
"""

# model/share

# # ## Some little utility functions.

AS.ConstructorIdentity = (constructor) -> (object) -> object.constructor is constructor
AS.Identity = (object) -> (other) -> object is other
AS.IdentitySort = (object) -> object

AS.loadPath = (path) ->
  target = require("pathology").Namespaces
  for segment in path.split(".")
    target = target[segment]
  target

AS.deepClone = (it) ->
  if _.isFunction(it)
    clone = it
  else if _.isArray(it)
    clone = _.clone(it)
  else if _.isObject(it)
    clone = {}
    for key, value of it
      if _.isArray(value) or _.isObject(value)
        clone[key] = AS.deepClone(value)
      else
        clone[key] = value
  else
    clone = it

  clone
# `uniq` generates a probably unique identifier.
# large random numbers are base32 encoded and combined with the current time base32 encoded
AS.uniq = ->
  (Math.floor Math.random() * 100000000000000000).toString(32) + "-" + (Math.floor Math.random() * 100000000000000000).toString(32) + "-" + (new Date).getTime().toString(32)

AS.humanSize = (size) ->
  units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  i = 0;
  while size >= 1024
    size /= 1024
    ++i

  if size
    size.toFixed(1) + ' ' + units[i]
  else
    "???"
