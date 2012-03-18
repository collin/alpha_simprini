{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

exports["AS.Models.RadioSelectionModel belongs_to selected"] = (test) ->
  test.ok AS.Models.RadioSelectionModel.properties.selected
  model = AS.Models.RadioSelectionModel.new()
  test.equal model.selected.get(), null
  test.done()
