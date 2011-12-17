module "AS.Views.VerticalSplit"
test "contains top, bottom and splitter elemens", ->
  view = new AS.Views.VerticalSplit()
  
  equal view.el.find(".Panel").length, 2, "contains two panels"
  ok view.el.find(":nth-child(2)").is(".Splitter"), "with a splitter in the middle"

test "allows configurable top, bottom and splitter elements", ->
  view = new AS.Views.VerticalSplit
    top: 'top', bottom: 'bottom', splitter: 'splitter'
  
  deepEqual [view.top, view.bottom, view.splitter], 'top bottom splitter'.split(" "), "lets you set them"

