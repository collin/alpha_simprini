AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.Dendrite = AS.Object.extend ({delegate, include, def, defs}) ->
  def initialize: (@observer, @notifier, @config={}) ->
    @callback = _.bind(@callback, this)
    @on()

  def callback: ->
    @observer.set(@notifier.get(), arguments)

  def on: ->
    @notifier.binds @callback
    @callback() if @config.triggerOnBind is true

  def off: ->
    @notifier.unbinds @callback

AS.Model.CollectionDendrite = AS.Model.Dendrite.extend ({delegate, include, def, defs}) ->
  def initialize: (@observer, @notifier, @config={}) ->
    @insertCallback = _.bind(@insertCallback, this)
    @removeCallback = _.bind(@removeCallback, this)
    @on()

  def insertCallback: (item, options) ->
    @observer.insert(item, options)
    
  def removeCallback: (item, options) ->
    @observer.remove(item, options)

  def on: ->
    @notifier.binds @insertCallback, @removeCallback

  def off: ->
    @notifier.unbinds @insertCallback, @removeCallback
    
