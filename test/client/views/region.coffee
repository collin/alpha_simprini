{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
module "Views Regions"
test "regions for cardinal directions/center extend Region", ->
  ok AS.Views.Region.new() instanceof AS.View
  ok AS.Views.North.new() instanceof AS.Views.Region
  ok AS.Views.East.new() instanceof AS.Views.Region
  ok AS.Views.South.new() instanceof AS.Views.Region
  ok AS.Views.West.new() instanceof AS.Views.Region
  ok AS.Views.Center.new() instanceof AS.Views.Region
  