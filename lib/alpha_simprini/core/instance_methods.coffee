AS = require("alpha_simprini")
_ = require "underscore"

AS.instance_methods = (klass) ->
  methods = _(klass.prototype).chain().keys()
  if klass.__super__
    methods.concat AS.instance_methods(klass.__super__.constructor)
  return methods.without("constructor", "initialize").value()