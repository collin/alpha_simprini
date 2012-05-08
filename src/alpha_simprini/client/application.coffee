{each} = _
domready = jQuery
require("jwerty")

AS.Application =  AS.Object.extend ({def, include}) ->
  include Taxi.Mixin

  def initialize: (config={}) ->
    _.extend(this, config)
    @params = AS.params
    @el ?= $("body")
    @godGivenKeyHandlers()
    domready =>
      @boot()
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """


  def boot: ->
  # @::boot.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def godGivenKeyHandlers: ->
    handlers =
      '⎋': 'escape'
      '⌘+↩': 'accept'
      'backspace': 'delete'

      #TODO: add to test suite
      "↩": "open"
      "up": "up"
      "down": "down"
      "home": "first"
      "end": "last"
      "left": "left"
      "right": "right"
      "tab": "indent"
      "shift+tab": "dedent"
      "[a-z]/[0-9]/shift+[a-z]": "alphanum"


    each handlers, (trigger, key) =>
      jwerty.key key, ( (event) => @trigger(trigger, event) ), @el

    jwerty.key "backspace", (event) =>
      @trigger("delete", event)
  # @::godGivenKeyHandlers.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def view: (constructor, options={}) ->
    options.application = this
    constructor.new options
  # @::view.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def append: (view) ->
    @el.append view.el
  # @::append.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

