module "Application",
  setup: ->
    @app = AS.Application.new(el: @el = $("<div>"))

test "attaches global key handlers w/jwerty", ->
  events = [
    "open", "up", "down", "first", "last", "left",
    "right", "indent", "dedent", "alphanum"
    "escape", "accept", "delete"
  ]

  app = @app
  for event in events
    do (event) =>
      app.bind event, (_event) -> ok(_event, "handled #{event}")

  triggers = [
    "esc", "cmd+enter", "backspace", "enter", "up", "down",
    "home", "end", "left", "right", "tab", "shift+tab"
    "a", "b", "C", "D", "1", "2"
  ]
  expect triggers.length


  for trigger in triggers
    jwerty.fire trigger, @el
    Taxi.Governer.exit()

test "initializes views into the application context", ->
  app_panel = @app.view AS.Views.Panel, key: "value"
  equal app_panel.application, @app
  equal app_panel.key, "value"

test "appends views into the app dom element", ->
  app_panel = @app.view AS.Views.Panel, key: "value"
  @app.append app_panel
  equal @app.el.children()[0], app_panel.el[0]
  