AS = require "alpha_simprini"

AS.Model.EmbedsMany = AS.Model.HasMany.extend()
AS.Model.EmbedsMany.Instance = AS.Model.HasMany.Instance.extend ({def, delegate}) ->
  def syncWith: (share) ->
    @share = share.at(@options.name)
    @share.set([]) if @share.get() in [null, undefined]

  def add: (item, options={}) ->
    item = @backingCollection.add.apply(@backingCollection, arguments)
    options.at ?= @backingCollection.length - 1
    item.didEmbed @share.at(options.at)
    return item

  def remove: (item) ->
    @backingCollection.remove.apply(@backingCollection, arguments)
    item.stopSync()
    return item

AS.Model.defs embedsMany: (name, options) -> 
  AS.Model.EmbedsMany.new(name, this, options)
