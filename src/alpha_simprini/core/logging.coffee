AS.warn = ->
  console.warn.apply(console, arguments)

COUNTS = Pathology.Map.new()
AS.count  = (key) ->
  count = COUNTS.get(key) ? 0
  COUNTS.set(key, count + 1)

AS.getCount = (key) ->
  COUNTS.get(key) ? 0

AS.error = () ->
  console.trace()
  console.error.apply(console, arguments)

AS.suppress_logging = ->
  AS.error = ->
  AS.warn = ->
