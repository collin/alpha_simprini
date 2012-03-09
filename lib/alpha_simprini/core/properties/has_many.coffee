AS = require("alpha_simprini")

AS.Model.HasMany = AS.Model.Field.extend()
AS.Model.HasMany.Instance = AS.Model.HasMany.Instance.extend
  
  initialize: (@object, @options={}) ->
    @backingCollection = AS.Collection.create(undefined, @options)

  set: (models) ->
    @backingCollection.add models

  add: (models) -> @backingCollection.add(models)

  remove: (models) -> @backingCollection.remove(models)

  bind: -> @backingCollection.bind.apply(@backingCollection, arguments)

  trigger: -> @backingCollection.trigger.apply(@backingCollection, arguments)

  unbind: -> @backingCollection.unbind.apply(@backingCollection, arguments)

AS.Model.HasMany.Instance.delegate AS.COLLECTION_DELEGATES, to: "backingCollection"
#FIXME: this should have worked
# AS.Model.HasMany.Instance.delegate "add", "remove", "bind", "unbind", "trigger", to: "backingCollection"

AS.Model.hasMany = (name, options) -> 
  AS.Model.HasMany.create(name, this, options)
