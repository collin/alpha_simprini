AS = require("alpha_simprini")
_ = require "underscore"

UNBIND_ALL = new Object
NO_PATH = new Object

AS.Event = new AS.Mixin
  instance_methods:
    _eventNamespacer: /\.([\w-_]+)$/

    parseSpec: (raw) ->
     if _.isString(raw)
        string = raw
        spec = {}

        if string.match @_eventNamespacer
          [name, namespace] = string.split(".")
          spec.path = if name then [name] else NO_PATH
          spec.namespace = namespace
        else
          spec.path = [string]
          spec.namespace = "none"
      else
        spec = raw
        spec.namespace = spec.namespace?.replace(/^\./, "") or "none"

      return spec

    bind: (spec, callback, context=this) ->
      spec = @parseSpec(spec)
      spec.context ?= context
      spec.callback = callback

      calls = @_callbacks ?= {}
      (calls[spec.namespace] ?= []).push spec

      return this

    recognize_path: (path_to_match, other_path) ->
      _(path_to_match).isEqual(other_path)

    unbind: (spec=UNBIND_ALL, callback) ->
      return this unless @_callbacks
      if spec is UNBIND_ALL
        delete @_callbacks
        return this

      spec = @parseSpec(spec)

      calls = @_callbacks

      # ISSUE, not possible to .unbind(".none")
      spec.path

      spec_filter = (_spec) ->
        if spec.path isnt NO_PATH
          # Don't use recognize_path here, we want to test against literally bound paths
          return false unless _(_spec.path).isEqual(spec.path)
        return false if callback and _spec.callback isnt callback
        return true

      if spec.namespace is "none"
        for key, value of calls
          calls[key] = _(calls[key]).reject(spec_filter)
      else if spec.path is NO_PATH
        delete calls[spec.namespace]
      else
        calls[spec.namespace] = _(calls[spec.namespace]).reject(spec_filter)

      return this

    trigger: (spec) ->
      return this unless @_callbacks
      spec = @parseSpec(spec)
      args = Array::slice.call(arguments, 1)
      for namespace, specs of @_callbacks
        continue if spec.namespace isnt "none" and spec.namespace isnt namespace
        for _spec in specs
          continue unless @recognize_path(_spec.path, spec.path)
          _spec.callback.apply(_spec.context, args)

      @trigger_all.call(this, spec, args)

    trigger_all: (spec, args) ->
      # # FIXME: DOWNSTREAM SHOULD BE RECEIVING PATH, NOT JUST PATH[0]
      args.unshift(spec.path[0])
      spec = AS.deep_clone(spec)
      spec.path = ["all"]

      for namespace, specs of @_callbacks
        continue if spec.namespace isnt "none" and spec.namespace isnt namespace
        for _spec in specs
          continue unless @recognize_path(_spec.path, spec.path)
          _spec.callback.apply(_spec.context, args)

