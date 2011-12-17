AS = require "alpha_simprini"
AS.InheritableAttrs = new AS.Mixin
  mixed_in: ->
    @class_inheritable_attrs = []

  class_methods:
    extended: ->
      @class_inheritable_attrs = _.clone(@class_inheritable_attrs)
      for attr in @class_inheritable_attrs
        @[attr] = AS.deep_clone(@[attr])

    class_inheritable_attr: (name, starter) ->
      unless @[name]
        @class_inheritable_attrs.push name
        @[name] = starter

      return @[name]
    
    write_inheritable_value: (name, key, value) ->
      @class_inheritable_attr(name, {})[key] = value
    
    push_inheritable_item: (name, item) ->
      @class_inheritable_attr(name, []).push(item)