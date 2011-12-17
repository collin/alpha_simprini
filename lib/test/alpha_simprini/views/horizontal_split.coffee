module "AS.Views.HorizontalSplit"
test "contains left, right and splitter elemens", ->
  view = new AS.Views.HorizontalSplit()
  
  equal view.el.find(".Panel").length, 2, "contains two panels"
  ok view.el.find(":nth-child(2)").is(".Splitter"), "with a splitter in the middle"

test "allows configurable left, right and splitter elements", ->
  view = new AS.Views.HorizontalSplit
    left: 'left', right: 'right', splitter: 'splitter'
  
  deepEqual [view.left, view.right, view.splitter], 'left right splitter'.split(" "), "lets you set them"

