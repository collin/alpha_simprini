AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.AbstractSynapse = AS.Object.extend ({delegate, include, def, defs}) ->
  defs create: (raw) ->
    if raw.constructor.Synapse
      raw.constructor.Synapse.new(raw)
    else
      null

  def initialize: (@raw)->
    @namespace = ".#{_.uniqueId('s')}"
    @observations = []
    @notifications = []

  def observe: (other, config={}) ->
    config.syncNow ?= true
    @observations.push @dendriteClass.new(this, other, config)

  def notify: (other, config={}) ->
    config.syncNow ?= false
    @notifications.push @dendriteClass.new(other, this, config)

  def block: (fn) ->
    @blocking = true
    fn()
    @blocking = undefined

  def stopObserving: (other) ->
    _(@observations).invoke('off')
    @observations = []

  def stopNotifying: (other) ->
    _(@notifications).invoke('off')
    @notifications = []

AS.Model.Synapse = AS.Model.AbstractSynapse.extend ({delegate, include, def, defs}) ->
  # def dendriteClass: AS.Model.Dendrite
  @::dendriteClass = AS.Model.Dendrite

  def binds: AS.unimplemented("binds: (callback) ->")
  def unbinds: AS.unimplemented("unbinds: (callback) ->")

  def get: AS.unimplemented("get: ->")
  def set: AS.unimplemented("set: (value) ->")

AS.Model.CollectionSynapse = AS.Model.AbstractSynapse.extend ({delegate, include, def, defs}) ->
  # def dendriteClass: AS.Model.CollectionDendrite
  # FIXME: don't super chain constructors!
  @::dendriteClass = AS.Model.CollectionDendrite

  def binds: AS.unimplemented("binds: (insertCallback, removeCallback) ->")
  def unbinds: AS.unimplemented("unbinds: (insertCallback, removeCallback) ->")

  def insert: AS.unimplemented("insert: (item, options) ->")
  def remove: AS.unimplemented("remove: (item) ->")

  def each: AS.unimplemented("each: (fn) ->")
        