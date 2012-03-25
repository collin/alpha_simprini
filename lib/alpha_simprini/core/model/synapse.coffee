AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.Synapse = AS.Object.extend ({delegate, include, def, defs}) ->
  defs create: (raw) ->
    if raw.constructor.Synapse
      raw.constructor.Synapse.new(raw)
    else
      null

  def initialize: (@raw)->
    @namespace = ".#{_.uniqueId('s')}"
    @observations = []
    @notifications = []

  def observe: (other, config) ->
    @observations.push AS.Model.Dendrite.new(this, other, config)

  def notify: (other, config) ->
    @notifications.push AS.Model.Dendrite.new(other, this, config)

  def stopObserving: (other) ->
    _(@observations).invoke('off')

  def stopNotifying: (other) ->
    _(@notifications).invoke('off')

  def binds: AS.unimplemented("binds: (interface, event, callback) ->")
  def unbinds: AS.unimplemented("unbinds: (interface, event, callback) ->")
  def get: AS.unimplemented("get: ->")
  def set: AS.unimplemented("set: (value) ->")
