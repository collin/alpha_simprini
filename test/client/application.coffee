{AS, $, _, sinon, jwerty} = require require("path").resolve("./test/client_helper")
exports.Application =
  setUp: (callback) ->
    @app = AS.Application.create()
    callback()

  "attaches global key handlers w/jwerty": (test) ->
    test.expect 3
    @app.bind "esc", (event) -> test.ok event
    @app.bind "accept", (event) -> test.ok event
    @app.bind "delete", (event) -> test.ok event
    jwerty.fire "esc"
    jwerty.fire "cmd+enter"
    jwerty.fire "backspace"
    test.done()

  # "initializes views into the application context": (test) ->
  #   app_panel = @app.view AS.Views.Panel, key: "value"
  #   test.equal app_panel.application, @app
  #   test.equal app_panel.key, "value"
  #   test.done()

  # "appends views into the app dom element": (test) ->
  #   app_panel = @app.view AS.Views.Panel, key: "value"
  #   @app.append app_panel
  #   test.equal @app.el.children()[0], app_panel.el[0]
  #   test.done()
