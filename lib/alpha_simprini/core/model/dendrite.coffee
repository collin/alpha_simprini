AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.Dendrite = AS.Object.extend ({delegate, include, def, defs}) ->
  def initialize: (@observer, @notifier, @config={}) ->
    @callback = _.bind(@callback, this)
    @on()

  def callback: ->
    return if @observer.blocking
    @observer.set(@notifier.get(), arguments)

  def equal: -> @notifier.get() is @observer.get()

  def on: ->
    @notifier.binds @callback
    return if @equal()
    @callback() unless _.isEmpty @notifier.get()

  def off: ->
    @notifier.unbinds @callback

AS.Model.CollectionDendrite = AS.Model.Dendrite.extend ({delegate, include, def, defs}) ->
  def initialize: (@observer, @notifier, @config={}) ->
    @insertCallback = _.bind(@insertCallback, this)
    @removeCallback = _.bind(@removeCallback, this)
    @on()

  def insertCallback: (item, options) ->
    return if @observer.blocking
    @observer.insert(item, options)

  def removeCallback: (item, options) ->
    return if @observer.blocking
    @observer.remove(item, options)

  def on: ->
    @notifier.binds @insertCallback, @removeCallback

    if @config.syncNow
      @notifier.each (item, index) =>
        @insertCallback(item, index)

  def off: ->
    @notifier.unbinds @insertCallback, @removeCallback

