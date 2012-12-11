class AS.Views.ColorPicker < AS.View
  def tagName: 'img'

  def events:
    "click": "pickColor"

  @afterContent (view) ->
    view.el.attr 'src', "/assets/jPicker/picker.gif"
    view.modelBinding().css 'background-color': ['rgba']
    view.modelBinding().paint()

  def pickColor: ->
    @colorPicker.pick @model
    
      