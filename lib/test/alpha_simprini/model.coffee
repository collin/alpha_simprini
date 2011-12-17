module "AS.Model"
test "All", ->
  model = new AS.Model
  equal AS.All.getByCid(model.cid), model, "All models are automatically addded to the All collection"
  
test "has_many", ->
  class AS.HasManyModel extends AS.Model
    @has_many 'things', model: -> "AS.HadModel"
  class AS.HadModel extends AS.Model
  
  deepEqual AS.HasManyModel.associations, ["things"], "stores the association in the association list"
  ok AS.HasManyModel.has_manys.things, "stores a configuration for the association"

  equal AS.HasManyModel.has_manys.things.model, undefined, "association collection configuration is lazy to allow associated class to load"  
  model = new AS.HasManyModel
  equal AS.HasManyModel.has_manys.things.model, AS.HadModel, "configures the collection class properly when needed"
  
  equal model.get("things").model, AS.HadModel, "association collection is auto-created"
  
  model.get("things").add {}
  
  equal model.get("things").at(0).constructor, AS.HadModel, "items added to the association are properly instantiated"
  
  model2 = new AS.HasManyModel
    things: [{}]
    
  equal model2.get("things").at(0).constructor, AS.HadModel, "items passed to constructor for the association are properly instantiated"

test "belongs to", ->
  class AS.Belonging extends AS.Model
    @belongs_to "parent"
  class AS.Owner extends AS.Model
    
  deepEqual AS.Belonging.associations, ["parent"], "stores the association on the class"
  
  ok AS.Belonging.belongs_to.parent, "stores a configuration object for the association on the class"
  
  owner = new AS.Owner id:"OWNERID"
  model = new AS.Belonging
  
  model.set parent:owner
  
  equal model.get("parent"), owner, "correctly sets the owner"
  
  model = new AS.Belonging
  
  model.set parent:owner.get("id")
  equal model.get("parent"), owner, "correctly sets the from a string id"
  
  proof = false
  model.bind "change:parent", -> proof = true
  owner.set some:"value"
  
  ok proof, "association changes trigger on the child"

  proof = false  
  new_owner = new AS.Owner
  model.set parent: new_owner
  new_owner.set some:"other value"
  
  ok proof, "changes trigger when associated model is changed"
  
  