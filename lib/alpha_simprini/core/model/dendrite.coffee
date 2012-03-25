AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.Dendrite = AS.Object.extend ({delegate, include, def, defs}) ->
  def initialize: (@observer, @notifier, @config={}) ->
    @callback = _.bind(@callback, this)
    @on()

  def callback: ->
    @observer.set(@notifier.get())

  def on: ->
    @notifier.binds @config.subjectInterface, @config.event, @callback
    @callback() if @config.triggerOnBind is true

  def off: ->
    @notifier.unbinds @config.subjectInterface, @config.event, @callback
