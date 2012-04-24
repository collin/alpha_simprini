AS = require "alpha_simprini"
_ = require "underscore"

AS.Model.EmbedsMany = AS.Model.HasMany.extend()
AS.Model.EmbedsMany.Instance = AS.Model.HasMany.Instance.extend ({def, delegate}) ->
  def syncWith: (share) ->
    @share = share.at(@options.name)
    if @share.get() in [null, undefined]
      @share.set([]) 
      @each (item, index) => item.didEmbed @share.at(index)
    else
      _.each @share.get(), (item, index) =>
        @add(item)

  def add: (item, options={}) ->
    console.log "add" if item instanceof Pasteup.Models.StyleComponent
    # console.warn "wrapping EmbedsMany add in a try"
    try
      item = @backingCollection.add.apply(@backingCollection, arguments)
      @triggerDependants()
      options.at ?= @backingCollection.length - 1
      item.didEmbed @share.at(options.at) if @share
      return item

  def remove: (item) ->
    index = @backingCollection.indexOf(item).value()
    @triggerDependants()
    @backingCollection.remove.apply(@backingCollection, arguments)
    @share.at(index).remove() if @share
    item.stopSync()
    return item

AS.Model.defs embedsMany: (name, options) -> 
  AS.Model.EmbedsMany.new(name, this, options)
