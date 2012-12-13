# DevChannel: reload
{defer} = _
class AS.Chassis.Frame
  include Taxi.Mixin

  def initialize: (X, @loadCallback) ->
    console.log "INITIALIZED"
    @frame = document.createElement('iframe')
    # @frame.src = "data:text/html;charset=utf-8," # BLANK DOCUMENT :D
    defer =>
      @dom = @frame.contentWindow
      @handleload()
      # @dom.applicationCache.addEventListener 'updateready', bind(@handleupdateready, this), false

    $ =>
      $(@frame).css(width:0, height:0, border: 'none').appendTo(document.body)

  def boot: ->
    @dom.boot()

  def close: ->
    console.log "CLOSE FRAME"
    @dom.unbindGoverner?()
    @frame.src = "about:blank"
    $(@frame).remove()

  def handleEvent: (event) ->
    @["handle#{event.type}"](event)
  
  def handlemessage: (event) ->
    return unless event.source is @dom

  def handleload: (event) ->
    # @dom.applicationCache.update()
    Taxi.Governer.exit() if Taxi.Governer.currentLoop
    minispade.global = @dom
    @dom.minispade = minispade
    minispade.loaded = {}
    minispade.require("pasteup/pasteup")
    @dom.AS.params = AS.params
    @trigger 'load'
    Taxi.Governer.exit()

  def handleupdateready: (event) ->
    @dom.applicationCache.swapCache()
    @trigger 'update'

  def get: (path) ->
    value = @dom
    for item in path.split(".")
      continue if value is undefined
      value = value[item]

    value