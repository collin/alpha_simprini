AS = require("alpha_simprini")
AS.Callbacks = AS.Module.extend ({def, defs}) ->
  defs define_callbacks: (all) ->
    for key, callbacks of all
      do (key, callbacks) =>
        for callback in callbacks or []
          do (callback) =>
            @["#{key}_#{callback}"] = (fn) ->
              @pushInheritableItem("#{key}_#{callback}_callbacks", fn)
          
  def run_callbacks: (name) ->
    for callback in @constructor["#{name}_callbacks"] || []
      callback.call(null, this)