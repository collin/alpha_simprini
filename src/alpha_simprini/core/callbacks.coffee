{upperCamelize} = fleck

module AS.Callbacks
  defs defineCallbacks: (all) ->
    for key, callbacks of all
      do (key, callbacks) =>
        for callback in callbacks or []
          do (callback) =>
            @["#{key}#{upperCamelize callback}"] = (fn) ->
              @pushInheritableItem("#{key}#{upperCamelize callback}_callbacks", fn)
  # @defineCallbacks.doc =
  #   params: [
  #     ["all"]
  #   ]
  #   desc: """
  #
  #   """

  def runCallbacks: (name) ->
    for callback in @constructor["#{name}_callbacks"] || []
      callback.call(null, this)
  # @::runCallbacks.doc =
  #   params: [
  #     ["name", String, true]
  #   ]
  #   desc: """
  #
  #   """