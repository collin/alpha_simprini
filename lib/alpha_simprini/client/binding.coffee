AS = require("alpha_simprini")
_ = require "underscore"

class AS.Binding
  constructor: (@context, @model, @path, @options={}, @fn=undefined) ->
    @path = [@path] unless _.isArray(@path)
    @binding_path = AS.deep_clone(@path)
    @binding_path.splice @path.length - 1, 1, "change:#{_(@path).last()}"

    if _.isFunction(@options)
      [@fn, @options] = [@options, {}]

    @container = @context.$ @context.current_node
    @binding_group = @context.binding_group

    @content = @context.$ []

    if @will_group_bindings()
      @context.group_bindings (binding_group) =>
        @binding_group = binding_group
      @initialize()
    else
      @initialize()

  will_group_bindings: ->
    @constructor.will_group_bindings or _.isFunction(@fn)

  path_value: -> @model.read_path @path

  require_option: (name) ->
    return unless @options[name] is undefined
    throw new AS.Binding.MissingOption("You must specify the #{name} option for #{@constructor.name} bindings.")

  initialize: ->

class AS.Binding.MissingOption extends Error

class AS.Binding.Model
  constructor: (@context, @model, @content=$([])) ->
    @styles = {}
    @attrs = {}

  css: (properties) ->
    for property, options of properties
      do (property, options) =>
        if _.isArray(options)
          @styles[property] = => @model.read_path(options)
          painter = ->
            value = @styles[property]()
            @content.css property, value

          binding_path = AS.deep_clone(options)
          binding_path[options.length - 1] = "change:#{_(options).last()}"
          @context.binds @model, binding_path, painter, this
        else
          @styles[property] = => options.fn(@model)
          painter = -> @content.css property, @styles[property]()
          for field in options.field.split(" ")
            @context.binds @model, "change:#{field}", painter, this

  attr: (attrs) ->
     for property, options of attrs
       do (property, options) =>
          if _.isArray(options)
            @attrs[property] = =>
              value = @model.read_path(options)
              if value is true
                "yes"
              else if value is false
                "no"
              else
                value

            painter = -> @content.attr property, @attrs[property]()

            binding_path = AS.deep_clone(options)
            binding_path[options.length - 1] = "change:#{_(options).last()}"
            @context.binds @model, binding_path, painter, this
          else
            @attrs[property] = =>
              if options.fn
                options.fn(@model)
              else
                if @model[options.field]() then "yes" else "no"

            painter = -> @content.attr property, @attrs[property]()

            for field in options.field.split(" ")
              @context.binds @model, "change:#{field}", painter, this

  paint: =>
    attrs = {}
    attrs[key] = fn() for key, fn of @attrs

    styles = {}
    styles[property] = fn() for property, fn of @styles

    @content.attr attrs
    @content.css styles
    @content.width @width_fn() if @width_fn
    @content.height @height_fn() if @height_fn

class AS.Binding.Field extends AS.Binding

  initialize: ->
    @content = @make_content()
    @bind_content()
    @set_content()

  bind_content: ->
    @context.binds @model, @binding_path, @set_content, this

  set_content: =>
    if @fn
      @container.empty()
      @binding_group.unbind()
      @context.within_binding_group @binding_group, =>
        @context.within_node @container, =>
          @fn.call(@context)
    else
      @content.text @path_value()

  make_content: ->
    if @fn
      @context.$ []
    else
      @context.$ @context.span()

class AS.Binding.Input extends AS.Binding.Field
  initialize: ->
    super
    @context.binds @model, @binding_path, @set_content, this

  make_content: ->
    @context.$ @context.input(@options)

  bind_content: ->
    @context.binds @content, "change", @set_field, this

  set_content: () =>
    @content.val @path_value()

  set_field: () =>
    @model.write_path @path, @content.val()

class AS.Binding.Select extends AS.Binding.Input
  constructor: ->
    super
    @require_option "options"

  make_content: ->
    options = @options.options
    @select = @context.$ @context.select ->
      if _.isArray options
        for option in options
          @option option.toString()
      else
        for key, value of options
          @option value: value, -> key

  set_content: () =>
    path_value = @path_value()
    path_value = @path_value.id if path_value?.id
    @content.val path_value

  set_field: =>
    value = @select.val()
    if _.isArray value
      @model.write_path @path, value[0]
    else
      @model.write_path @path, value


class AS.Binding.CheckBox extends AS.Binding.Input
  set_content: ->
    @content.attr "checked", @path_value()

  bind_content: ->
    @context.binds @content, "change", @set_field, this

  set_field: =>
    if @content.is ":checked"
      @model.write_path @path, true
    else
      @model.write_path @path, false

  initialize: ->
    @options.type = "checkbox"
    super

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

  transform_insert_cursor = (text, position, cursor) ->
    if position < cursor
      cursor + text.length
    else
      cursor

  transform_delete_cursor = (text, position, cursor) ->
    if position < cursor
      cursor - Math.min(text.length, cursor - position)
    else
      cursor

  initialize: ->
    @options.contentEditable = true
    @content = @make_content()
    @elem = @content[0]
    @elem.innerHTML = @path_value()
    @previous_value = @path_value()
    @selection = start: 0, end: 0

    @context.binds @model, "share:insert:#{_(@path).last()}", @insert, this
    @context.binds @model, "share:delete:#{_(@path).last()}", @delete, this

    @context.binds @model, "change:#{_(@path).last()}", @updateUnlessFocused, this

    for event in ['textInput', 'keydown', 'keyup', 'select', 'cut', 'paste', 'click', 'focus']
      @context.binds @content, event, @generate_operation, this

  updateUnlessFocused: (event) ->
    # Defer this because we want text input to feel fluid!
    _.defer =>
      return if @context.$(this.elem).closest(":focus")[0]
      @elem.innerHTML = @path_value()

  make_content: ->
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
    @selection.start = transform_insert_cursor(text, position, @selection.start)
    @selection.end = transform_insert_cursor(text, position, @selection.end)

    @replace_text @elem.innerHTML[...position] + text + @elem.innerHTML[position..]

  delete: (model, position, text) ->
    @selection.start = transform_delete_cursor(text, position, @selection.start)
    @selection.end = transform_delete_cursor(text, position, @selection.end)

    @replace_text @elem.innerHTML[...position] + @elem.innerHTML[position + text.length..]

  generate_operation: =>
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
      @applyChange @model.share.at(@path), @model.share.at(@path).getText(), @elem.innerHTML.replace(/\r\n/g, '\n')
      @model[@path] @model.share.at(@path).getText(), remote: true

class AS.Binding.HasMany extends AS.Binding
  @will_group_bindings = true

  initialize: ->
    @collection = @path_value()

    @contents = {}
    @bindings = {}

    @collection.each @make_content

    @context.binds @collection, "add", @insert_item, this
    @context.binds @collection, "remove", @remove_item, this
    @context.binds @collection, "change", @change_item, this

  skip_item: (item) ->
    return false unless @options.filter

    for key, value of @options.filter
      expected_value = _([value]).flatten()
      value_on_item = item[key]?()

      return true unless _(expected_value).include(value_on_item)

    false

  insert_item: (item) =>
    return if @skip_item(item)
    content = @context.dangling_content => @make_content(item)
    index = @collection.indexOf(item).value?()
    index ?= 0
    siblings = @container.children()
    if siblings.get(0) is undefined or siblings.get(index) is undefined
      @container.append(content)
    else
      @context.$(siblings.get(index)).before(content)

  remove_item: (item) =>
    if @contents[item.cid]
      @contents[item.cid].remove()
      delete @contents[item.cid]

      @bindings[item.cid].unbind()
      delete @bindings[item.cid]

  change_item: (item) =>
    if @skip_item(item)
      @remove_item(item)
    else if @contents[item.cid] is undefined
      @insert_item(item)

  make_content: (item) =>
    return if @skip_item(item)
    content = @context.$ []
    @context.within_binding_group @binding_group, =>
      @context.group_bindings =>
        @bindings[item.cid] = @context.binding_group
        binding = new AS.Binding.Model(@context, item, content)
        made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
        if made?.jquery
          content.push made[0]
        else
          content.push made

        binding.paint()

    @contents[item.cid] = content
    return content

class AS.Binding.EmbedsMany extends AS.Binding.HasMany
class AS.Binding.EmbedsOne extends AS.Binding.Field
  @will_group_bindings = true

class AS.Binding.HasOne extends AS.Binding.Field
  @will_group_bindings = true

class AS.Binding.Collection extends AS.Binding.HasMany
  path_value: -> @model

# use case: RadioSelectionModel
# ala-BAM-a
# @element_focus.binding "selected", (element) ->
#   new Author.Views.ElementBoxAS.Binding(this, @div class:"Focus", element)
#
# @element_selection.binding "selected", (element) ->
#   new Author.Views.ElementBoxBinding(this, @div class:"Selection", element)

class AS.Binding.BelongsTo extends AS.Binding
  @will_group_bindings = true

  initialize: ->
    @make_content()
    @context.within_binding_group @binding_group, =>
      @context.binds @model, @binding_path, @changed, this

  changed: =>
    @content.remove()
    @binding_group.unbind()
    @initialize()

  make_content: ->
    item = @path_value()
    if item
      @context.within_binding_group @binding_group, =>
        @context.within_node @container, =>
          @content = @context.$ []
          binding = new AS.Binding.Model(@context, item, @content)
          made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
          if made?.jquery
            @content.push made[0]
          else
            @content.push made
          binding.paint()
          @content
    else
      @content = @context.$ []
