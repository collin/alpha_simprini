AS = require("alpha_simprini")
AS.error = () -> 
  console.trace()
  console.error.apply(console, arguments)
