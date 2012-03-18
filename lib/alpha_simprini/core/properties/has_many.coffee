AS = require("alpha_simprini")

AS.Model.HasMany = AS.Model.Field.extend()
AS.Model.HasMany.Instance = AS.Model.Field.Instance.extend ({def, delegate}) ->
  delegate AS.COLLECTION_DELEGATES, to: "backingCollection"
  
  def initialize: (@object, @options={}) ->
    @backingCollection = AS.Collection.new(undefined, @options)

  def set: (models) ->
    @backingCollection.add models

  def add: (models) -> @backingCollection.add.apply(@backingCollection, arguments)

  def at: (models) -> @backingCollection.at.apply(@backingCollection, arguments)

  def remove: (models) -> @backingCollection.remove.apply(@backingCollection, arguments)

  def bind: -> @backingCollection.bind.apply(@backingCollection, arguments)

  def trigger: -> @backingCollection.trigger.apply(@backingCollection, arguments)

  def unbind: -> @backingCollection.unbind.apply(@backingCollection, arguments)

#FIXME: this should have worked
# AS.Model.HasMany.Instance.delegate "add", "remove", "bind", "unbind", "trigger", to: "backingCollection"

AS.Model.defs hasMany: (name, options) -> 
  AS.Model.HasMany.new(name, this, options)
