AS = require("alpha_simprini")
_ = require "underscore"

SKIP_METHODS = [
  'objectId'
  'readPath'
  'path'
  '_name'
  '_readId'
  '_container'
  '_path'
  '_createProperties'
  'propertiesThatCouldBe'
  'toString'
  'constructor'
]

AS.instanceMethods = (klass) ->
  methods = _(klass.prototype).chain().keys()
  if klass.__super__
    methods = methods.concat AS.instanceMethods(klass.__super__.constructor)
  return methods.without(SKIP_METHODS).value()