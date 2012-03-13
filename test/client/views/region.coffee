{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
exports["Views Regions"] =
  "regions for cardinal directions/center extend Region": (test) ->
    test.ok AS.Views.Region.new() instanceof AS.View
    test.ok AS.Views.North.new() instanceof AS.Views.Region
    test.ok AS.Views.East.new() instanceof AS.Views.Region
    test.ok AS.Views.South.new() instanceof AS.Views.Region
    test.ok AS.Views.West.new() instanceof AS.Views.Region
    test.ok AS.Views.Center.new() instanceof AS.Views.Region
    test.done()
