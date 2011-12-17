_ = require("underscore")
# Extended to allow "Nested.Modules"
_module = exports.module = (name, fn) ->
  if _.isString(name)
    [name, more...] = name.split "."
    if not @[name]?
      this[name] = {}
    if not @[name].unit?
      @[name].module = _module
  
    if more[0] is undefined
      if fn is undefined
        @[name]
      else
        fn.call(@[name])
    else
      @[name].unit more.join("."), fn
  else
    fn?.call(name)
    name