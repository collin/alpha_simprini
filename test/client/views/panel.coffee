{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
exports["Views Panel"] =
  "Panel extends View": (test) ->
    test.ok new AS.Views.Panel instanceof AS.View

    test.done()
