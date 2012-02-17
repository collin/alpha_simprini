AS = require("alpha_simprini")

AS.warn = ->
  if window.DEBUGGER
    console.warn.apply(console, arguments)

AS.error = () ->
  console.trace()
  console.error.apply(console, arguments)

AS.suppress_logging = ->
  AS.error = ->
  AS.warn = ->
