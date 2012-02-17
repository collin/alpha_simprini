{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
exports["Views Regions"] =
  "regions for cardinal directions/center extend Region": (test) ->
    test.ok new AS.Views.Region instanceof AS.View
    test.ok new AS.Views.North instanceof AS.Views.Region
    test.ok new AS.Views.East instanceof AS.Views.Region
    test.ok new AS.Views.South instanceof AS.Views.Region
    test.ok new AS.Views.West instanceof AS.Views.Region
    test.ok new AS.Views.Center instanceof AS.Views.Region
    test.done()
