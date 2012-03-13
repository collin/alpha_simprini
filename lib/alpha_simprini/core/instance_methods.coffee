AS = require("alpha_simprini")
_ = require "underscore"

AS.instanceMethods = (klass) ->
  methods = _(klass.prototype).chain().keys()
  if klass.__super__
    methods = methods.concat AS.instanceMethods(klass.__super__.constructor)
  return methods.without("constructor", "initialize").value()