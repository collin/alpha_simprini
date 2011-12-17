module "AS.Views.Stage"
test "is a Panel", -> 
  ok (new AS.Views.Stage).el.is(".Panel")
test "Comes with a canvas inside it", ->
  view = new AS.Views.Stage
  ok view.el.find(".Canvas").is(".ASView")
test "allows setting any canvas", ->
  equal (new AS.Views.Stage canvas:"canvas").canvas, "canvas"