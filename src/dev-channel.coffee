{bind} = _
class DevChannel
  def initialize: (@host, @port, Socket=WebSocket) ->
    @connect()

  def connect: ->
    @socket?.close()
    @socket = Socket.new("ws://#{@host}:#{port}")
    @socket.onmessage = bind(@onmessage, this)
    @socket.onclose = bind(@onclose, this)
    @socket.onerror = bind(@onclose, this)

  def onmessage: ({data}) ->
    @trampoline = undefined
    if data.protocol
      @[data.protocol].apply(this, data.arguments)

  def onclose: (event) ->
    @trampoline ||= 1
    if @trampoline
      console.log "Attempting reconnect #{@trampoline}/3"
    @trampoline++
  
    if @trampoline < 3
      @connect() 
    else
      console.error "Unexpectedly Closed DevChannel", event
      console.info "Reason Unknown"
      console.log "reload page to reconnect"

  def loadStylesheet: (path, source) ->
  
  def loadScript: (path, source) ->
    console.log "loadScript", path, source
    minispade.modules[path] = source
    minispade.flushCache()
    
