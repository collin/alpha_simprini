AS = require("alpha_simprini")
Taxi = require("taxi")
{each} = require("underscore")
jwerty = require("jwerty").jwerty
domready = $ = require("jquery")

AS.Application =  AS.Object.extend ({def, include}) ->
  include Taxi.Mixin

  def initialize: () ->
    @params = AS.params
    @god_given_key_handlers()
    domready =>
      @boot()

    @el ?= $("body")

  def boot: ->

  def god_given_key_handlers: ->
    handlers =
      '⎋': 'esc'
      '⌘+↩': 'accept'
      '⌫': 'delete'

    each handlers, (trigger, key) =>
      jwerty.key key, (event) =>
        @trigger(trigger, event)

  def view: (constructor, options={}) ->
    options.application = this
    constructor.new options

  def append: (view) ->
    @el.append view.el

