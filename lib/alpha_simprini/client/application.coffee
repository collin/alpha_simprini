AS = require("alpha_simprini")
_ = require "underscore"
jwerty = require("jwerty").jwerty
domready = $ = require("jQuery")

class AS.Application
  AS.Event.extends(this)

  constructor: (args) ->
    domready =>
      @params = AS.params
      @god_given_key_handlers()
      @initialize?()

    @el ?= $("body")

  god_given_key_handlers: ->
    handlers =
      '⎋': 'esc'
      '⌘+↩': 'accept'
      '⌫': 'delete'

    _(handlers).each (trigger, key) =>
      jwerty.key key, (event) =>
        @trigger(trigger, event)

  view: (constructor, options={}) ->
    options.application = this
    new constructor options

  append: (view) ->
    @el.append view.el


