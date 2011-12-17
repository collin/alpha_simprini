AS = require("alpha_simprini")
_ = require "underscore"
AS.Delegate = new AS.Mixin
  class_methods:
    delegate: (delegated_methods..., options) ->
      delegatee = options.to
      callOrReturn = (object, fn_or_object, args) ->
        if _.isFunction(fn_or_object)
          fn_or_object.apply(object, args)
        else
          object
          
      _(delegated_methods).chain().flatten().each (method) =>
        if _.isString(delegatee)
          @::[method] = -> 
            _delegatee = @[delegatee]
            callOrReturn _delegatee, _delegatee[method], arguments
        else if _.isFunction(delegatee)
          @::[method] = -> 
            _delegatee = delegatee()
            callOrReturn _delegatee, _delegatee[method], arguments
        else
          @::[method] = -> callOrReturn delegatee, delegatee[method], arguments
