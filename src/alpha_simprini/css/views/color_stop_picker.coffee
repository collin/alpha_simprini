require "knead"
{defer} = _

class ColorStopHandle < AS.View
  def events:    
    "knead:dragstart": "dragstartStop"
    "knead:drag": "dragStop"
    "dblclick": "pickColor"

  def content: ->
    @span class: "pointer"
    @span class: "handle"

    @modelBinding().css
      "left":
        field: ["stop"]
        fn: => "#{@model.stop.get()}%"
      "background-color":
        field: ["rgba"]
        fn: => @model.rgba.get()
    defer => @modelBinding().paint()

  def dragstartStop: (event) ->
    @startx = parseFloat(@el.position().left, 10)
 
  def dragStop: (event) ->
    x = @startx + event.deltaX
    percent = 100 * (x / 300).toPrecision(2)
    percent = Math.min(100, Math.max(0, percent))
    @model.stop.set(percent)

  def pickColor: (event) ->
    event.stopPropagation()
    @colorPicker.pick @model


class ColorStopPicker < AS.View
  @afterContent (view) ->
    knead.monitor view.el

  def events:    
    "dblclick ol": "addStop"

  def content: ->
    @view AS.Views.AnglePicker, model: @model.angle.get()
    @section class: "ColorStops", ->
      @svg ->
        @defs ->
          @linearGradient id:@objectId(), ->
            @model.binding "stops", order_by: "stop", (colorStop, binding) ->
   
              stop = @stop()
              binding.attr
                offset:
                  field: ["stop"]
                  fn: -> "#{colorStop.stop.get()}%"
                "stop-color":
                  field: ["rgba"]
                  fn: -> colorStop.rgba.get()
              
              _.defer -> binding.paint()
   
              return stop
   
        @g ->
          @rect width: 300, height: 20, fill: "url(##{@objectId()})"
   
      @ol -> @model.binding "stops", order_by: "stop", @stopHandle
  
  def stopHandle: (colorStop, binding) ->
    @view AS.Views.ColorStopHandle, 
      el: @li(class:'stop')
      model: colorStop
      colorPicker: @colorPicker
  
  def addStop: ->
   @model.stops.add stop: 50
