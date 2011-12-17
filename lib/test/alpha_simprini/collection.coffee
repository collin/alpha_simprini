module "AS.Collection"
test "adding a model to a collection with @inverse and @source property specified", ->
  collection = new (AS.Collection.extend(inverse: "inverse", source: "source"))
  model = new AS.Model
  
  collection.add model
  equal model.get('inverse'), "source", "sets collection to property on model"