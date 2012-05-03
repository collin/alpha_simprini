AS.Binding.Model = AS.Object.extend ({def}) ->
  def initialize: (@context, @model, @content=$([])) ->
    @styles = {}
    @attrs = {}

  def css: (properties) ->
    for property, options of properties
      do (property, options) =>
        if _.isArray(options)
          @styles[property] = => @model.readPath(options)
          painter = =>
            value = @styles[property]()
            @content.css property, value

          @context.binds @model, options, painter, this
        else
          @styles[property] = => options.fn(@model)
          painter = => @content.css property, @styles[property]()
          @context.binds @model, options.field, painter, this

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

            painter = =>
              @content.attr property, @attrs[property]()

            bindingPath = options
            @context.binds @model, bindingPath, painter, this
          else
            @attrs[property] = =>
              if options.fn
                options.fn(@model)
              else
                value = @model[options.field].get()
                if value is true
                  "yes"
                else if vaule is false
                  "no"
                else
                  value

            painter = =>
              @content.attr property, @attrs[property]()

            @context.binds @model, options.field, painter, this

  def paint: ->
    attrs = {}
    attrs[key] = fn() for key, fn of @attrs

    styles = {}
    styles[property] = fn() for property, fn of @styles

    @content.attr attrs
    @content.css styles
    @content.width @width_fn() if @width_fn
    @content.height @height_fn() if @height_fn
