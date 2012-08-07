require "rangy-core"
AS.Binding.EditLine = AS.Binding.extend ({def}) ->
  def rangy: rangy

  def applyChange:  (doc, oldval="", newval="") ->
    return if oldval is newval
    return if newval is ""
    doc.set "" unless doc.get()
    commonStart = 0
    commonStart++ while oldval.charAt(commonStart) == newval.charAt(commonStart)

    commonEnd = 0
    commonEnd++ while oldval.charAt(oldval.length - 1 - commonEnd) == newval.charAt(newval.length - 1 - commonEnd) and
      commonEnd + commonStart < oldval.length and commonEnd + commonStart < newval.length

    doc.del commonStart, oldval.length - commonStart - commonEnd unless oldval.length == commonStart + commonEnd
    doc.insert commonStart, newval[commonStart ... newval.length - commonEnd] unless newval.length == commonStart + commonEnd
  # @::applyChange.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def transformInsertCursor = (text, position, cursor) ->
    if position < cursor
      cursor + text.length
    else
      cursor
  # @::transformInsertCursor.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def transformDeleteCursor = (text, position, cursor) ->
    if position < cursor
      cursor - Math.min(text.length, cursor - position)
    else
      cursor
  # @::transformDeleteCursor.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def initialize: ->
    @_super.apply(this, arguments)
    @options.contentEditable = true
    @content = @makeContent()
    @elem = @content[0]
    @elem.innerHTML = @fieldValue()
    @previousValue = @fieldValue()
    @selection = start: 0, end: 0

    @context.binds @model, "share:insert:#{@field.options.name}", @insert, this
    @context.binds @model, "share:delete:#{@field.options.name}", @delete, this

    @context.binds @model, "change:#{@field.options.name}", @updateUnlessFocused, this

    for event in ['textInput', 'keydown', 'keyup', 'select', 'cut', 'paste', 'click', 'focus']
      @context.binds @content, event, @generateOperation, this
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def updateUnlessFocused: (event) ->
    # Defer this because we want text input to feel fluid!
    _.defer =>
      return if $(@elem).closest(":focus")[0]
      @elem.innerHTML = @fieldValue()
  # @::updateUnlessFocused.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def makeContent: ->
    @context.$ @context.span(@options)
  # @::makeContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def replaceText: (newText="") ->
    range = @rangy.createRange()
    selection = @rangy.getSelection()

    scrollTop = @elem.scrollTop
    @elem.innerHTML = newText
    @elem.scrollTop = scrollTop unless @elem.scrollTop is scrollTop

    return unless selection.anchorNode?.parentNode is @elem
    range.setStart(selection.anchorNode || @elem.childNodes[0] || @elem, @selection.start)
    range.collapse(true)
    selection.setSingleRange(range)
  # @::replaceText.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def insert: (model, position, text) ->
    @selection.start = transformInsertCursor(text, position, @selection.start)
    @selection.end = transformInsertCursor(text, position, @selection.end)

    @replaceText @elem.innerHTML[...position] + text + @elem.innerHTML[position..]
  # @::insert.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def delete: (model, position, text) ->
    @selection.start = transformDeleteCursor(text, position, @selection.start)
    @selection.end = transformDeleteCursor(text, position, @selection.end)

    @replaceText @elem.innerHTML[...position] + @elem.innerHTML[position + text.length..]
  # @::delete.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def generateOperation: ->
    if @model.share
      selection = @rangy.getSelection()
      if selection.rangeCount
        range = @rangy.getSelection().getRangeAt(0)
      else
        range = @rangy.createRange()
      @selection.start = range.startOffset
      @selection.end = range.endOffset
      if @elem.innerHTML isnt @previousValue
        @previousValue = @elem.innerHTML
        # IE constantly replaces unix newlines with \r\n. ShareJS docs
        # should only have unix newlines.
        @applyChange @model.share.at(@field.options.name), @model.share.at(@field.options.name).getText(), @elem.innerHTML.replace(/\r\n/g, '\n')
        @model[@field.options.name].set @model.share.at(@field.options.name).getText()
    else
      if @elem.innerHTML isnt @previousValue
        @previousValue = @elem.innerHTML
        @field.set @elem.innerHTML
    return
  # @::generateOperation.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """