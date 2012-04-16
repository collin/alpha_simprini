AS = require("alpha_simprini")
_ = require "underscore"
$ = require "jquery"

AS.Binding.Model = AS.Object.extend ({def}) ->
  def initialize: (@context, @model, @content=$([])) ->
    @styles = {}
    @attrs = {}

  def css: (properties) ->
    for property, options of properties
      do (property, options) =>
        if _.isArray(options)
          @styles[property] = => @model.readPath(options)
          painter = => _.defer =>
            value = @styles[property]()
            @content.css property, value

          bindingPath = options
          @context.binds @model, bindingPath, painter, this
        else
          @styles[property] = => options.fn(@model)
          painter = => _.defer => @content.css property, @styles[property]()
          for field in options.field.split(" ")
            @context.binds @model, "change:#{field}", painter, this

  def attr: (attrs) ->
     for property, options of attrs
       do (property, options) =>
          if _.isArray(options)
            @attrs[property] = =>
              value = @model.readPath(options)
              if value is true
                "yes"
              else if value is false
                "no"
              else
                value

            painter = => _.defer =>
              @content.attr property, @attrs[property]()

            bindingPath = options
            @context.binds @model, bindingPath, painter, this
          else
            @attrs[property] = =>
              if options.fn
                options.fn(@model)
              else
                if @model[options.field].get() then "yes" else "no"

            painter = => _.defer =>
              @content.attr property, @attrs[property]()

            for field in options.field.split(" ")
              @context.binds @model, "change:#{field}", painter, this

  def paint: ->
    attrs = {}
    attrs[key] = fn() for key, fn of @attrs

    styles = {}
    styles[property] = fn() for property, fn of @styles

    @content.attr attrs
    @content.css styles
    @content.width @width_fn() if @width_fn
    @content.height @height_fn() if @height_fn
