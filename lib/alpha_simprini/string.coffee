String::underscore = ->
  under = @replace(/([A-Z])/g, (match) -> "_#{match}")
  if under[0] is "_"
    under.slice(1).toLowerCase()
  else
    under.toLowerCase()

String::camelcase = ->
  @replace(/^([a-z])|_([a-z])|-([a-z])/g, (match) -> match.toUpperCase()).replace(/-|_/, '')

String::dasherize = ->
  @underscore().replace(/_/g, '-')
  