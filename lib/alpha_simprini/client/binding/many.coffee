AS = require("alpha_simprini")
_ = require "underscore"

AS.Binding.Many = AS.Binding.extend ({def}) ->
  @willGroupBindings = true

  def initialize: ->
    @_super.apply(this, arguments)
    @collection = @field

    @contents = {}
    @bindings = {}
    @sorting = @sortedModels()

    @makeAll()

    console.log "THEFUCKS"
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
