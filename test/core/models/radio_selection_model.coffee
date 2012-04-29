{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

module "AS.Models.RadioSelectionModel" 

test "belongsTo selected", ->
  ok AS.Models.RadioSelectionModel.properties.selected
  model = AS.Models.RadioSelectionModel.new()
  equal model.selected.get(), null
  