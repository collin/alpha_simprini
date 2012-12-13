class AS.Binding.Model < AS.Binding
  def initialize: (@context, @model, @content=$([])) ->
    @styles = {}
    @attrs = {}
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def css: (properties) ->
    # for property, options of properties
    #   do (property, options) =>
    #     if _.isArray(options)
    #       options = {
    #         path: options
    #         fn: =>
    #           value = @styles[property]()
    #           @content.css property, value
    #       }

    #     @styles[property] = => options.fn(@model)
    #     painter = => _.defer => @content.css property, @styles[property]()

    #     {path} = options

    #     @context.binds @model, options.path, painter, this

    _.defer => @paint()

  # @::css.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def attr: (attrs) ->
    for property, path of attrs
      do (property, path) =>
        @attrs[property] = => @model.readPath(path)
        painter = =>
          value = @attrs[property]()
          @content.attr property, value

        @context.binds @model, path, painter, this

    _.defer => @paint()

  # @::attr.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def paint: ->
    attrs = {}
    attrs[key] = fn() for key, fn of @attrs

    styles = {}
    styles[property] = fn() for property, fn of @styles

    @content.attr attrs
    @content.css styles
  # @::paint.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """
