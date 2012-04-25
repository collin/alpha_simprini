require "rangy-core"
AS.Binding.EditLine = AS.Binding.extend ({def}) ->
  def rangy: rangy

  def applyChange:  (doc, oldval, newval) ->
    return if oldval == newval
    commonStart = 0
    commonStart++ while oldval.charAt(commonStart) == newval.charAt(commonStart)

    commonEnd = 0
    commonEnd++ while oldval.charAt(oldval.length - 1 - commonEnd) == newval.charAt(newval.length - 1 - commonEnd) and
      commonEnd + commonStart < oldval.length and commonEnd + commonStart < newval.length

    doc.del commonStart, oldval.length - commonStart - commonEnd unless oldval.length == commonStart + commonEnd
    doc.insert commonStart, newval[commonStart ... newval.length - commonEnd] unless newval.length == commonStart + commonEnd

  def transformInsertCursor = (text, position, cursor) ->
    if position < cursor
      cursor + text.length
    else
      cursor

  def transformDeleteCursor = (text, position, cursor) ->
    if position < cursor
      cursor - Math.min(text.length, cursor - position)
    else
      cursor

  def initialize: ->
    @_super.apply(this, arguments)
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

  def updateUnlessFocused: (event) ->
    # Defer this because we want text input to feel fluid!
    _.defer ->
      return if @context.$(this.elem).closest(":focus")[0]
      @elem.innerHTML = @fieldValue()

  def makeContent: ->
    @context.$ @context.span(@options)

  def replace_text: (new_text="") ->
    range = @rangy.createRange()
    selection = @rangy.getSelection()

    scrollTop = @elem.scrollTop
    @elem.innerHTML = new_text
    @elem.scrollTop = scrollTop unless @elem.scrollTop is scrollTop

    return unless selection.anchorNode?.parentNode is @elem
    range.setStart(selection.anchorNode || @elem.childNodes[0] || @elem, @selection.start)
    range.collapse(true)
    selection.setSingleRange(range)

  def insert: (model, position, text) ->
    @selection.start = transformInsertCursor(text, position, @selection.start)
    @selection.end = transformInsertCursor(text, position, @selection.end)

    @replace_text @elem.innerHTML[...position] + text + @elem.innerHTML[position..]

  def delete: (model, position, text) ->
    @selection.start = transformDeleteCursor(text, position, @selection.start)
    @selection.end = transformDeleteCursor(text, position, @selection.end)

    @replace_text @elem.innerHTML[...position] + @elem.innerHTML[position + text.length..]

  def generateOperation: ->
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
