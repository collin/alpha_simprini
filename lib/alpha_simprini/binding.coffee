AS = require("alpha_simprini")
_ = require "underscore"

class AS.Binding  
  constructor: (@context, @model, @field, @options={}, @fn=undefined) ->
    if _.isFunction(@options)
      [@fn, @options] = [@options, {}]
    
    @container = $ @context.current_node
    @binding_group = @context.binding_group
    
    @content = $ []

    if @constructor.will_group_bindings?
      @context.group_bindings (binding_group) => 
        @binding_group = binding_group
        @initialize()
    else
      @initialize()
  
  field_value: -> @model[@field]()
  
class AS.Binding.Model
  constructor: (@context, @model, @content=$([])) ->
    @styles = {}
    @attrs = {}
  
  css: (properties) ->
    for property, options of properties
      do (property, options) =>
        @styles[property] = => 
          options.fn(@model)
        
        painter = -> @content.css property, @styles[property]()

        for field in options.field.split(" ")
          @context.binds @model, "change:#{field}", painter, this
  
  attr: (attrs) ->
     for property, options of attrs
       do (property, options) =>
          @attrs[property] = =>
            if options.fn
              options.fn(@model)
            else
              if @model[options.field]() then "yes" else "no"
        
          painter = -> @content.attr property, @attrs[property]()
          
          for field in options.field.split(" ")
            @context.binds @model, "change:#{field}", painter, this
  
  width: (fn) ->
    @width_fn = =>
      fn(@model)
  
  height: (fn) ->
    @height_fn = =>
      fn(@model)
  
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
    @set_content()
    @context.binds @model, "change:#{@field}", @set_content, this

  set_content: =>
    @content.text @field_value()

  field_value: ->
    @fn?() or super

  make_content: ->
    $ @context.span()
    
class AS.Binding.Input extends AS.Binding.Field

  make_content: ->
    input = $ @context.input(@options)
    @context.binds input, "change", @set_field, this
    input
    
  set_content: () ->
    @content.val @field_value()
  
  set_field: () =>
    @model[@field] @content.val()

class AS.Binding.EditLine extends AS.Binding
  applyChange = (doc, oldval, newval) ->
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
    @elem.innerHTML = @field_value()
    @previous_value = @field_value()
    @selection = start: 0, end: 0
    
    @context.binds @model, "share:insert:#{@field}", @insert, this
    @context.binds @model, "share:delete:#{@field}", @delete, this
    
    for event in ['textInput', 'keydown', 'keyup', 'select', 'cut', 'paste', 'click', 'focus']
      @context.binds @content, event, @generate_operation, this
    
  make_content: ->
    $ @context.span(@options)
  
  replace_text: (new_text="") ->
    range = rangy.createRange()
    selection = rangy.getSelection()
    
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
    
  generate_operation: () =>
    selection = rangy.getSelection()
    if selection.rangeCount
      range = rangy.getSelection().getRangeAt(0)
    else
      range = rangy.createRange()
    @selection.start = range.startOffset
    @selection.end = range.endOffset
    _.defer =>
      if @elem.innerHTML isnt @previous_value
        @previous_value = @elem.innerHTML
        # IE constantly replaces unix newlines with \r\n. ShareJS docs
        # should only have unix newlines.
        applyChange @model.share.at(@field), @model.share.at(@field).getText(), @elem.innerHTML.replace(/\r\n/g, '\n')
    
class AS.Binding.HasMany extends AS.Binding
  @will_group_bindings = true
  
  initialize: ->
    @collection = @field_value()
    
    @contents = {}
    @bindings = {}
        
    @collection.each @make_content
    
    @context.binds @collection, "add", @insert_item, this
    @context.binds @collection, "remove", @remove_item, this

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
      $(siblings.get(index)).before(content)
    
  remove_item: (item) =>
    return if @skip_item(item)
    @contents[item.cid].remove()
    delete @contents[item.cid]
    
    @bindings[item.cid].unbind()
    delete @bindings[item.cid]

  make_content: (item) =>
    return if @skip_item(item)
    content = $ []
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

class AS.Binding.Collection extends AS.Binding.HasMany
  field_value: -> @model

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
      @context.binds @model, "change:selected", @selection_changed, this

  selection_changed: =>
    @content.remove()
    @binding_group.unbind()
    @initialize()
    
  make_content: ->
    item = @field_value()
    if item
      @context.within_binding_group @binding_group, =>
        @context.within_node @container, =>
          @content = $ []
          binding = new AS.Binding.Model(@context, item, @content)
          made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
          if made?.jquery
            @content.push made[0]
          else
            @content.push made
          binding.paint()
          @content
    else
      @content = $ []
