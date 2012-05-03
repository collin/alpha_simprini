module "AS.Models.RadioSelectionModel"

test "belongsTo selected", ->
  ok AS.Models.RadioSelectionModel.properties.selected
  model = AS.Models.RadioSelectionModel.new()
  equal model.selected.get(), null
  