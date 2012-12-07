class AnglePicker < AS.View
  @afterContent (view) ->
    knead.monitor view.el

  def events:
    "knead:dragstart": "pickAngle"
    "knead:drag": "pickAngle"


  def pickAngle: (event) ->
    {clientX, clientY} = event.originalEvent
    target = @picker
    offset = target.offset()
    [centerX, centerY] = [offset.left + 20, offset.top + 20]
    [deltaX, deltaY] = [centerX - clientX, centerY - clientY]

    degrees = -1 * (Math.atan2(deltaX, deltaY) * 180 / Math.PI)
    target.trigger($.Event "change", degrees: degrees)

  def content: ->
    r = 20
    r2 = r*2

    indicatorTransform = =>
      "translate(#{r}, #{r}) rotate(#{@model.degrees.get() or 0})"

    @picker = $ @svg width: r2 + 5, height: r2, class: "angle-selector", ->
      @defs ->
        @radialGradient id: @objectId(), cx: "50%", cy: "50%", r:"0.48", ->
          @stop offset: 0.85, "stop-color": "#ddd"
          @stop offset: 0.95, "stop-color": "#fff"
          @stop offset: 1, "stop-color": "#777"
      @circle x1: r, y1:r, cx: r, cy: r, r: r, fill: "url(##{@objectId()})"
      @indicator = $ @g transform: indicatorTransform(), ->
        @line x1:0, y1:0, x2:0, y2:-r, "stroke-width": 0.5, stroke: "black"
    
    @binds @picker, "change", (event) =>
      @model.degrees.set event.degrees

    @binds @model, ["degrees"], =>
      @indicator.attr("transform", indicatorTransform())
