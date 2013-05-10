{isArray} = _
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
    for property, options of properties
      do (property, options) =>
        if _.isArray(options)
          @styles[property] = => @model.readPath(options)
          painter = => _.defer =>
            value = @styles[property]()
            @content.css property, value

          @context.binds @model, options, painter, this
        else
          @styles[property] = => options.fn(@model)
          painter = => _.defer => @content.css property, @styles[property]()
          @context.binds @model, options.field, painter, this
  # @::css.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def attr: (attrs) ->
    for property, options of attrs
      do (property, options) =>
         if property is "selected"
            throw "Property #{property} given in attrBinding will not behave as expected. Use another property name."
         if _.isArray(options)
           @attrs[property] = =>
             value = @model.readPath(options)
             if value is true
               "yes"
             else if value in [false, null, undefined]
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
               value = @model[options.field].get()
               if value is true
                 "yes"
               else if value in [false, null, undefined]
                 "no"
               else
                 value
           painter = => _.defer =>
             @content.attr property, @attrs[property]()
           @context.binds @model, options.field, painter, this

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
