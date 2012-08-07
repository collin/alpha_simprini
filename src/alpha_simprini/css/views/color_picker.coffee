AS.Views.ColorPicker = AS.View.extend ({delegate, include, def, defs}) ->
  def tagName: 'img'

  def events:
    "click": "pickColor"

  @afterContent (view) ->
    view.el.attr 'src', "/assets/jPicker/picker.gif"
    view.modelBinding().css 'background-color': ['rgba']
    view.modelBinding().paint()

  def pickColor: ->
    @colorPicker.pick @model
    
      