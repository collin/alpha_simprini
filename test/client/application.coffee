{AS, $, _, sinon, jwerty} = require require("path").resolve("./test/client_helper")
exports.Application =
  setUp: (callback) ->
    @app = AS.Application.new(el: @el = $("<div>"))
    callback()

  "attaches global key handlers w/jwerty": (test) ->
    events = [
     "open", "up", "down", "first", "last", "left", 
     "right", "indent", "dedent", "alphanum"
     "escape", "accept", "delete"
    ]

    for event in events
      do (event) =>
        @app.bind event, (_event) -> test.ok(_event)

    triggers = [
      "esc", "cmd+enter", "backspace", "enter", "up", "down",
      "home", "end", "left", "right", "tab", "shift+tab"
      "a", "b", "C", "D", "1", "2"
    ]
    test.expect triggers.length


    for trigger in triggers
      jwerty.fire trigger, @el

    test.done()

  "initializes views into the application context": (test) ->
    app_panel = @app.view AS.Views.Panel, key: "value"
    test.equal app_panel.application, @app
    test.equal app_panel.key, "value"
    test.done()

  "appends views into the app dom element": (test) ->
    app_panel = @app.view AS.Views.Panel, key: "value"
    @app.append app_panel
    test.equal @app.el.children()[0], app_panel.el[0]
    test.done()
