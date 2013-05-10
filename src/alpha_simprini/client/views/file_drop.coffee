class AS.Views.FileDrop < AS.View
  @afterContent (view) -> view.enable()

  def enabledEvents:
    "dragenter": "dragenter"
    "dragend": "dragend"
    "dragleave": "dragleave"
    "dragover": "dragover"
    "drop": "drop"

  def disable: ->
    @exitState('enabled')

  def enable: ->
    @enterState('enabled')

  def dragenter: (event) ->
    @addClass("targeted")
    event.preventDefault()
    event.stopImmediatePropagation()

  def dragend: (event) ->
    @removeClass("targeted")
    event.preventDefault()
    event.stopImmediatePropagation()

  def dragleave: (event) ->
    @removeClass("targeted")
    event.preventDefault()
    event.stopImmediatePropagation()

  def dragover: (event) ->
    event.preventDefault()
    event.stopImmediatePropagation()

  def drop: (event) ->
    event.preventDefault()
    event.stopPropagation()
    @removeClass("targeted")
    transfer = event.originalEvent.dataTransfer

    if "Files" in transfer.types
      for file in transfer.files
        @trigger("drop:file", file)

    if "text/html" in transfer.types
      jQuery(transfer.getData("text/html")).filter("img").each (index, image) =>
        @trigger("drop:html", image)
  