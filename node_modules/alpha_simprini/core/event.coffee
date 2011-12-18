AS = require("alpha_simprini")
_ = require "underscore"
AS.Event = new AS.Mixin
  instance_methods: 
    _eventNamespacer: /\.([\w-_]+)$/
    bind: (ev, callback, context) ->
      if not (callback and context)
        AS.error """
        Attempted to bind an event #{ev} without a callback AND a context.
        Both are required.
        callback: #{callback}
        context: #{context}
        """
        
      if match = ev.match @_eventNamespacer
        [ev, namespace] = ev.split(".")
      namespace ?= 'none'
    
      calls = @_callbacks ?= {}
      list = calls[ev] ?= { none: [] }
    
      list[namespace] ?= []
      list[namespace].push [callback, context]
      this
    
    unbind: (ev, callback) ->
      if !ev
        delete @_callbacks
      else if calls = @_callbacks
        if !callback
          if ev[0] is "."
            namespace = ev.slice(1)
            for event, namespaces of calls
              namespaces[namespace] = []
          else
            return this unless calls[ev.split(".")[0]]
            if match = ev.match @_eventNamespacer
              [ev, namespace] = ev.split(".")
              calls[ev][namespace] = []
            else
              calls[ev] = { none: [] }
        else
          for key, handlers of calls[ev]
            calls[ev][key] = _(handlers).reject (handler) -> handler[0] is callback
            # for handler, index in handlers
            #   delete handlers[index] if handler[0] is callback
            #   break
            # # Delete leaves around [undefined] nonsense
            # cals[ev][key] = _.compact(handlers)
            
      this

    trigger: (eventName) ->
      return this unless calls = @_callbacks
      if eventName.match @_eventNamespacer
        [eventName, namespace] = eventName.split(".")
      both = 2
      while both--
        ev = if both
          eventName
        else
          'all'
        if list = calls[ev]
          if namespace and ev isnt 'all'
            if list[namespace]
              for handler in list[namespace]
                args = if both
                  Array::slice.call(arguments, 1)
                else
                  arguments
                handler[0].apply(handler[1] || this, args)            
          else
            for key, handlers of list
              for handler in handlers
                args = if both
                  Array::slice.call(arguments, 1)
                else
                  arguments
                handler[0].apply(handler[1] || this, args)
      this
