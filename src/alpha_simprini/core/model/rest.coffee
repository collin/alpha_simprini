{camelize, underscore, pluralize, singularize} = fleck

convertKeys = (object) ->
  converted = {}
  for key, value of object
    converted[camelize key] = value
  converted

extractIds = (object) ->
  data = {}
  ids = {}
  for key, value of object
    if key.match(/Id$/) and not(object[key.replace(/Id$/, "Type")])
      ids[key] = value
    else if key.match /Ids$/
      ids[key] = value
    else
      data[key] = value

  [data, ids]

AS.Model.REST = AS.Module.extend ({delegate, include, def, defs}) ->
  defs mappings: AS.Map.new()

  defs rootKey: ->
    underscore @_name()

  defs resourcesURL: -> "/#{pluralize @rootKey()}"

  defs resourceURL: (id) -> "#{@resourcesURL()}/#{id}"

  defs load: (id, callback) ->
    unless model = AS.All.byId[id]
      model = @new()
      callback ?= model.didLoad
      @readOne id, _.bind(callback, model)

    return model

  def didLoad: (data) ->
    @loadData(data)

  defs readOne: (id, callback) ->
    $.ajax
      url: @resourceURL(id)
      dataType: 'json'
      success: callback
      error: =>
        console.error "readone error"
        console.error(this, arguments)

  defs mappings: ->
    mappings = {}
    for klass in @appendedTo
      mappings[pluralize(camelize(klass.rootKey()))] = klass
    mappings


  def loadData: (data) ->
    references = AS.Map.new()
    root = @constructor.rootKey()

    # TODO: implement runtime assertions
    # assert data[root], "loaded data for, but JSON had no data at rootKey: #{root}"

    modelData = data[root]
    modelData = convertKeys(modelData)

    [modelData, ids] = extractIds(modelData)

    @set(modelData)

    references.set(this, ids)

    for key, embeds of convertKeys(data)
      continue if key is root
      # assert AS.Model.REST.mappings[key], "sideload data provided for #{key}, but no mapping exists in AS.Model.REST.mappings"
      @constructor.mappings()[key].sideloadData(embed, references) for embed in embeds

    references.each (model, ids) -> model.resolveReferences(ids)
    references.each (model) -> model.trigger("ready")
    # @trigger("ready")
    return this

  defs sideloadData: (modelData, references) ->
    modelData = convertKeys(modelData)
    [modelData, ids] = extractIds(modelData)
    model = @new(modelData)

    references.set(model, ids)

  def resolveReferences: (ids) ->
    for key, references of ids
      continue unless references

      if references.length is undefined
        relationKey = key.replace(/Id$/, '')
        path = @[relationKey].model().path()
        id = references
        @[relationKey].set AS.All.byIdRef["#{id}-#{path}"]

      else
        relationKey = pluralize key.replace(/Ids$/, '')
        path = @[relationKey].model().path()
        for id in references
          item = AS.All.byIdRef["#{id}-#{path}"]
          relation = @[relationKey]

          # careful not to double-add at load time
          continue if relation.include(item).value()
          relation.add(item)

    