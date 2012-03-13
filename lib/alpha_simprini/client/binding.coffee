AS = require("alpha_simprini")
_ = require "underscore"

AS.Binding = AS.Object.extend ({def}) ->
  def initialize: (@context, @model, @field, @options={}, @fn=undefined) ->
    @event = "change:#{field}"

    if _.isFunction(@options)
      [@fn, @options] = [@options, {}]

    @container = @context.$ @context.currentNode
    @bindingGroup = @context.bindingGroup

    @content = @context.$ []

    if @willGroupBindings()
      @context.groupBindings (bindingGroup) ->
        @bindingGroup = bindingGroup
      @setup()
    else
      @setup()

  def willGroupBindings: ->
    @constructor.willGroupBindings or _.isFunction(@fn)

  def fieldValue: -> @field.get()

  def require_option: (name) ->
    return unless @options[name] is undefined
    throw new AS.Binding.MissingOption("You must specify the #{name} option for #{@constructor.name} bindings.")

  def setup: ->

class AS.Binding.MissingOption extends Error

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

          bindingPath = AS.deepClone(options)
          bindingPath[options.length - 1] = "change:#{_(options).last()}"
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

            bindingPath = AS.deepClone(options)
            bindingPath[options.length - 1] = "change:#{_(options).last()}"
            @context.binds @model, bindingPath, painter, this
          else
            @attrs[property] = =>
              if options.fn
                options.fn(@model)
              else
                if @model[options.field]() then "yes" else "no"

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

AS.Binding.Field = AS.Binding.extend ({def}) ->

  def initialize: ->
    @_super.apply this, arguments
    @content = @makeContent()
    @bindContent()
    @setContent()

  def bindContent: ->
    @context.binds @field, "change", @setContent, this

  def setContent: ->
    if @fn
      @container.empty()
      @bindingGroup.unbind()
      @context.withinBindingGroup @bindingGroup, =>
        @context.withinNode @container, =>
          @fn.call(@context)
    else
      @content.text @fieldValue()

  def makeContent: ->
    if @fn
      @context.$ []
    else
      @context.$ @context.span()

AS.Binding.Input = AS.Binding.Field.extend ({def}) ->
  def initialize: ->
    @_super.apply(this, arguments)
    @context.binds @field, "change", @setContent, this

  def makeContent: ->
    @context.$ @context.input(@options)

  def bindContent: ->
    @context.binds @content, "change", _.bind(@setField, this)

  def setContent: () ->
    @content.val @fieldValue()

  def setField: () ->
    @field.set @content.val()

AS.Binding.Select = AS.Binding.Input.extend ({def}) ->
  def initialize: ->
    @_super.apply(this, arguments)
    @require_option "options"

  def makeContent: ->
    options = @options.options
    @select = @context.$ @context.select ->
      if _.isArray options
        for option in options
          @option option.toString()
      else
        for key, value of options
          @option value: value, -> key

  def setContent: () ->
    fieldValue = @fieldValue()
    fieldValue = fieldValue.id if fieldValue?.id
    @content.val fieldValue

  def setField: ->
    value = @select.val()
    if _.isArray value
      @field.set value[0]
    else
      @field.set value


AS.Binding.CheckBox = AS.Binding.Input.extend ({def}) ->
  def initialize: (context, model, field, options={}, fn=undefined) ->
    options.type = "checkbox"
    @_super.apply(this, arguments)

  def setContent: ->
    @content.attr "checked", @fieldValue()

  def bindContent: ->
    @context.binds @content, "change", _.bind(@setField, this)

  def setField: ->
    if @content.is ":checked"
      @field.set true
    else
      @field.set false


class AS.Binding.EditLine extends AS.Binding
  rangy: require("rangy-core")

  applyChange:  (doc, oldval, newval) ->
    return if oldval == newval
    commonStart = 0
    commonStart++ while oldval.charAt(commonStart) == newval.charAt(commonStart)

    commonEnd = 0
    commonEnd++ while oldval.charAt(oldval.length - 1 - commonEnd) == newval.charAt(newval.length - 1 - commonEnd) and
      commonEnd + commonStart < oldval.length and commonEnd + commonStart < newval.length

    doc.del commonStart, oldval.length - commonStart - commonEnd unless oldval.length == commonStart + commonEnd
    doc.insert commonStart, newval[commonStart ... newval.length - commonEnd] unless newval.length == commonStart + commonEnd

  transformInsertCursor = (text, position, cursor) ->
    if position < cursor
      cursor + text.length
    else
      cursor

  transformDeleteCursor = (text, position, cursor) ->
    if position < cursor
      cursor - Math.min(text.length, cursor - position)
    else
      cursor

  initialize: ->
    @options.contentEditable = true
    @content = @makeContent()
    @elem = @content[0]
    @elem.innerHTML = @fieldValue()
    @previous_value = @fieldValue()
    @selection = start: 0, end: 0

    @context.binds @model, "share:insert:#{_(@field).last()}", @insert, this
    @context.binds @model, "share:delete:#{_(@field).last()}", @delete, this

    @context.binds @model, "change:#{_(@field).last()}", @updateUnlessFocused, this

    for event in ['textInput', 'keydown', 'keyup', 'select', 'cut', 'paste', 'click', 'focus']
      @context.binds @content, event, @generateOperation, this

  updateUnlessFocused: (event) ->
    # Defer this because we want text input to feel fluid!
    _.defer ->
      return if @context.$(this.elem).closest(":focus")[0]
      @elem.innerHTML = @fieldValue()

  makeContent: ->
    @context.$ @context.span(@options)

  replace_text: (new_text="") ->
    range = @rangy.createRange()
    selection = @rangy.getSelection()

    scrollTop = @elem.scrollTop
    @elem.innerHTML = new_text
    @elem.scrollTop = scrollTop unless @elem.scrollTop is scrollTop

    return unless selection.anchorNode?.parentNode is @elem
    range.setStart(selection.anchorNode || @elem.childNodes[0] || @elem, @selection.start)
    range.collapse(true)
    selection.setSingleRange(range)

  insert: (model, position, text) ->
    @selection.start = transformInsertCursor(text, position, @selection.start)
    @selection.end = transformInsertCursor(text, position, @selection.end)

    @replace_text @elem.innerHTML[...position] + text + @elem.innerHTML[position..]

  delete: (model, position, text) ->
    @selection.start = transformDeleteCursor(text, position, @selection.start)
    @selection.end = transformDeleteCursor(text, position, @selection.end)

    @replace_text @elem.innerHTML[...position] + @elem.innerHTML[position + text.length..]

  generateOperation: ->
    selection = @rangy.getSelection()
    if selection.rangeCount
      range = @rangy.getSelection().getRangeAt(0)
    else
      range = @rangy.createRange()
    @selection.start = range.startOffset
    @selection.end = range.endOffset
    if @elem.innerHTML isnt @previous_value
      @previous_value = @elem.innerHTML
      # IE constantly replaces unix newlines with \r\n. ShareJS docs
      # should only have unix newlines.
      @applyChange @model.share.at(@field), @model.share.at(@field).getText(), @elem.innerHTML.replace(/\r\n/g, '\n')
      @model[@field] @model.share.at(@field).getText(), remote: true

AS.Binding.Many = AS.Binding.extend ({def}) ->
  @willGroupBindings = true

  def initialize: ->
    @_super.apply(this, arguments)
    @collection = @field

    @contents = {}
    @bindings = {}
    @sorting = @sortedModels()

    @makeAll()

    @context.binds @collection, "add", @insertItem, this
    @context.binds @collection, "remove", @removeItem, this
    @context.binds @collection, "change", @changeItem, this

  def makeAll: ->
    @sortedModels().each _.bind @makeContent, this

  def sortedModels: ->
    if sortField = @options.order_by
      @collection.sortBy((item) -> item[sortField]())
    else
      @collection

  def skipItem: (item) ->
    return false unless @options.filter

    for key, value of @options.filter
      expectedValue = _([value]).flatten()
      valueOnItem = item[key]?.get()
      return true unless _(expectedValue).include(valueOnItem)

    false

  def insertItem: (item) ->
    return if @skipItem(item)
    content = @context.danglingContent => @makeContent(item)
    index = @sortedModels().indexOf(item).value?()
    index ?= 0
    siblings = @container.children()
    if siblings.get(0) is undefined or siblings.get(index) is undefined
      @container.append(content)
    else
      @context.$(siblings.get(index)).before(content)

    @sorting = @sortedModels()

  def removeItem: (item) ->
    if @contents[item.cid]
      @contents[item.cid].remove()
      delete @contents[item.cid]

      @bindings[item.cid].unbind()
      delete @bindings[item.cid]

    @sorting = @sortedModels()

  def moveItem: (item) ->
    content = @contents[item.cid]
    currentIndex = content.index()
    newIndex = @sortedModels().indexOf(item).value()
    siblings = content.parent().children()

    if currentIndex < newIndex
      @context.$(siblings[newIndex]).after(content)
    else if newIndex < currentIndex
      @context.$(siblings[newIndex]).before(content)

  def changeItem: (item) ->
    if @options.order_by and @sorting.indexOf(item).value() isnt @sortedModels().indexOf(item).value()
      @moveItem(item)
      @sorting = @sortedModels()

    if @skipItem(item)
      @removeItem(item)
    else if @contents[item.cid] is undefined
      @insertItem(item)

  def makeContent: (item) ->
    return if @skipItem(item)
    content = @context.$ []
    @context.withinBindingGroup @bindingGroup, =>
      @context.groupBindings =>
        @bindings[item.cid] = @context.bindingGroup
        binding = new AS.Binding.Model(@context, item, content)
        made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
        if made?.jquery
          content.push made[0]
        else
          content.push made

        # FIXME: paint!
        # binding.paint()

    @contents[item.cid] = content
    return content

# class AS.Binding.EmbedsMany extends AS.Binding.HasMany
# class AS.Binding.EmbedsOne extends AS.Binding.Field
#   @willGroupBindings = true

# class AS.Binding.HasOne extends AS.Binding.Field
#   @willGroupBindings = true

# class AS.Binding.Collection extends AS.Binding.HasMany
#   fieldValue: -> @model

# # use case: RadioSelectionModel
# # ala-BAM-a
# # @element_focus.binding "selected", (element) ->
# #   new Author.Views.ElementBoxAS.Binding(this, @div class:"Focus", element)
# #
# # @element_selection.binding "selected", (element) ->
# #   new Author.Views.ElementBoxBinding(this, @div class:"Selection", element)

# class AS.Binding.BelongsTo extends AS.Binding
#   @willGroupBindings = true

#   initialize: ->
#     @makeContent()
#     @context.withinBindingGroup @bindingGroup, ->
#       @context.binds @model, @event, @changed, this

#   changed: ->
#     @content.remove()
#     @bindingGroup.unbind()
#     @initialize()

#   makeContent: ->
#     item = @fieldValue()
#     if item
#       @context.withinBindingGroup @bindingGroup, ->
#         @context.withinNode @container, ->
#           @content = @context.$ []
#           binding = new AS.Binding.Model(@context, item, @content)
#           made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
#           if made?.jquery
#             @content.push made[0]
#           else
#             @content.push made
#           binding.paint()
#           @content
#     else
#       @content = @context.$ []
