AS = require("alpha_simprini")
Taxi = require("taxi")
{each} = require("underscore")
jwerty = require("jwerty").jwerty
domready = $ = require("jquery")
_ = require "underscore"

AS.Application =  AS.Object.extend ({def, include}) ->
  include Taxi.Mixin

  def initialize: (config={}) ->
    _.extend(this, config)
    @params = AS.params
    @el ?= $("body")
    @god_given_key_handlers()
    domready =>
      @boot()


  def boot: ->

  def god_given_key_handlers: ->
    handlers =
      '⎋': 'escape'
      '⌘+↩': 'accept'
      '⌫': 'delete'

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

  def view: (constructor, options={}) ->
    options.application = this
    constructor.new options

  def append: (view) ->
    @el.append view.el

