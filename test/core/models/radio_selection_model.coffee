{AS, _, sinon, coreSetUp} = require require("path").resolve("./test/helper")
exports.setUp = coreSetUp

exports["AS.Models.RadioSelectionModel belongs_to selected"] = (test) ->
  test.ok AS.Models.RadioSelectionModel.belongs_tos.selected
  model = new AS.Models.RadioSelectionModel
  test.equal model.selected(), null
  test.done()
