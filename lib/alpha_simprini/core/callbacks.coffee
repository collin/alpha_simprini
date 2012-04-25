AS = require("alpha_simprini")
{upperCamelize} = require("fleck")

AS.Callbacks = AS.Module.extend ({def, defs}) ->
  defs defineCallbacks: (all) ->
    for key, callbacks of all
      do (key, callbacks) =>
        for callback in callbacks or []
          do (callback) =>
            @["#{key}#{upperCamelize callback}"] = (fn) ->
              @pushInheritableItem("#{key}#{upperCamelize callback}_callbacks", fn)

  # @::runCallbacks.doc =
  #   params: [
  #     ["name", String, true]
  #   ]
  #   desc: """
  #
  #   """
  def runCallbacks: (name) ->
    for callback in @constructor["#{name}_callbacks"] || []
      callback.call(null, this)