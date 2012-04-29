{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
module "Views Panel"
test "Panel extends View", ->
    ok new AS.Views.Panel instanceof AS.View

    