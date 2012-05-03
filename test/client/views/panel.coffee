module "Views Panel"
test "Panel extends View", ->
    ok new AS.Views.Panel instanceof AS.View

    