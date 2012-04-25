AS.Binding.Many = AS.Binding.extend ({def}) ->
  @willGroupBindings = true

  def initialize: ->
    @_super.apply(this, arguments)
    @collection = @field

    @contents = {}
    @bindingGroups = {}
    @sorting = @sortedModels()
    @makeAll()

    @context.binds @collection, "add", @insertItem, this
    @context.binds @collection, "remove", @removeItem, this
    @context.binds @collection, "change", @changeItem, this

  def makeAll: ->
    @sortedModels().each _.bind @makeItemContent, this

  def sortedModels: ->
    if sortField = @options.order_by
      @collection.sortBy((item) -> item[sortField].get())
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

    content = @context.danglingContent => @makeItemContent(item)
    index = @sortedModels().indexOf(item).value?()
    index ?= 0
    siblings = @container.children()

    unless siblings.get(0)
      @container.append(content)

    else unless siblings.get(index)
      @container.append(content)

    else
      @context.$(siblings.get(index)).before(content)

    debugger if window.DEBUG
    @sorting = @sortedModels()

  def removeItem: (item) ->
    if @contents[item.cid]
      @contents[item.cid].remove()
      delete @contents[item.cid]

      @bindingGroups[item.cid].unbind()
      delete @bindingGroups[item.cid]

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

  def makeItemContent: (item) ->
    return unless item
    return if @skipItem(item)
    content = @context.$ []
    @context.withinBindingGroup @bindingGroup, =>
      @context.groupBindings =>
        @bindingGroups[item.cid] = @context.bindingGroup
        binding = AS.Binding.Model.new(@context, item, content)
        made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
        if made?.jquery
          content.push made[0]
        else
          content.push made

        # FIXME: paint!
        binding.paint()

    @contents[item.cid] = content
    return content

  def makeContent: ->
    AS.Binding.Container.new(@container[0])
    