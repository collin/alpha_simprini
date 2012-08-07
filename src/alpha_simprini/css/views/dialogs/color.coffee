require "jpicker"

JPICKER_SETTINGS =
  images: clientPath: "/assets/jPicker/"
  window:
    alphaSupport:true
    alphaPrecision:2


AS.Views.Dialogs.Color = AS.Views.Dialog.extend ({delegate, include, def, defs}) ->
  def events:
    "dblclick .Map": "triggerCommit"
    "dblclick .Bar": "triggerCommit"

  def headerContent: -> @label "Color Picker"

  def color: () ->
    @active_color().val()

  def active_color: ->
    @picker[0].color.active

  def current_color: ->
    @picker[0].color.current

  def pick: (color) ->
    bg = "." + color.objectId()

    set_color = (picked) =>
     color.set
      red: picked.r
      green: picked.g
      blue: picked.b
      alpha: picked.a

    @bind "change#{bg}", _.throttle(set_color, 100)
    @bind "commit#{bg}", set_color
    @bind "cancel#{bg}", set_color

    @bind "close#{bg}", => @unbind(bg)

    @open(color.ahex?.get()[1..] or "000000ff")

  def open: (color, type="ahex") ->
    @el.find(".Map > span").css("position", "relative")
    @current_color().val(type, color)
    @active_color().val(type, color)
    @_super()

  def triggerChange: ->
    @trigger "change", @color()

  def triggerCommit: ->
    @current_color().val('ahex', @active_color().val('ahex'));
    @trigger "commit", @color()
    @close()

  def triggerCancel: ->
    @current_color().val('ahex', @current_color().val('ahex'));
    @trigger "cancel", @color()
    @close()

  def initialize: ->
    @_super.apply(this, arguments)
    @picker = @content.jPicker JPICKER_SETTINGS, (->), _.bind(@triggerChange, this)
    @close()

