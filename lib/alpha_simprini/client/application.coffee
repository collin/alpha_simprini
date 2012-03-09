AS = require("alpha_simprini")
Taxi = require("taxi")
{each} = require("underscore")
jwerty = require("jwerty").jwerty
domready = $ = require("jquery")

AS.Application =  AS.Object.extend
  initialize: () ->
    @params = AS.params
    @god_given_key_handlers()
    domready =>
      @boot()

    @el ?= $("body")

  boot: ->

  god_given_key_handlers: ->
    handlers =
      '⎋': 'esc'
      '⌘+↩': 'accept'
      '⌫': 'delete'

    each handlers, (trigger, key) =>
      jwerty.key key, (event) =>
        @trigger(trigger, event)

  view: (constructor, options={}) ->
    options.application = this
    constructor.create options

  append: (view) ->
    @el.append view.el

Taxi.Mixin.extends AS.Application
