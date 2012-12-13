# how to use
# chassis = Chassis.Block.new("http://pasteup-lite.dev/editor.js", "editor")
# FIXME: publish chassis-only alpha_simprini package
# DevChannel: reload
class AS.Chassis.Block

  def initialize: (@application) ->
    @appname = "app"
    # window.addEventListener "message", bind(@forwardMessage, this), false
    $ =>
      @viewport = $(document.createElement("section"))
      @viewport.addClass("Viewport")
      @viewport.appendTo(document.body)
      $(document).bind "devchannel:script", (=> @loadFrame())
      @loadFrame()

  # def forwardMessage: (event) ->
  #   console.log "forwardMessage", event.data
  #   if event.source is @currentFrame.dom
  #     console.log "to opener"
  #     window.opener?.postMessage(event.data, "*")
  #   else if event.source is window.opener
  #     console.log "to currentFrame"
  #     @currentFrame.dom.postMessage(event.data, "*")

  def log: (args...) ->
    console.log "[Chassis.Block]", args...
    
  def loadFrame: ->
    @lastFrame = @currentFrame
    @currentFrame = AS.Chassis.Frame.new()
    # @currentFrame.bind 'update', (=> @loadFrame())
    @currentFrame.bind 'load', (=> @cutOver())

  def cutOver: ->
    console.profile()
    @log "cutOver"
    @currentFrame.dom.AS.DOM.def _document: document
    @currentFrame.boot()
    
    currentApp = @currentFrame.get("Pasteup."+@appname)

    if @lastFrame?
      lastApp = @lastFrame.get("Pasteup."+@appname)

      # first pass instantiates
      for id, object of @lastFrame.get("AS.All.byId")
        # console.log "[prepare] #{object.toString()} #{id}"
        currentApp.prepareModel(id, object)
      
      # second pass does the takeover      
      for id, object of @lastFrame.get("AS.All.byId")
        # console.log "[takeOverModel] #{object.toString()} #{id}"
        currentApp.takeOverModel(id, object)

      # console.log "TAKE OVER STATE"
      currentApp.takeOverState(lastApp)
      lastApp.keyRouter.reroute(null)

    @lastFrame?.close()
    @viewport.empty()
    currentApp.applyTo(@viewport)
    currentApp.keyRouter.reroute(document.body)
    window.Pasteup = @currentFrame.dom.Pasteup
    console.profileEnd()
