AS = require "alpha_simprini"
{camelize, underscore, pluralize} = require "fleck"
isArray = require "underscore"
$ = require "jquery"

convertKeys = (object) ->
  converted = {}
  for key, value of object
    converted[camelize key] = value
  converted

extractIds = (object) ->
  data = {}
  ids = {}
  for key, value of object
    if key.match /Ids?$/
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

  defs readOne: (id) ->
    $.get
      url: @resourceURL(id)
      dataType: 'json'
      success: _.bind(@loadData, this)
      error: =>
        console.error "readone error"
        console.error(this, arguments)

  defs mappings: ->
    mappings = {}
    for klass in @appendedTo
      mappings[pluralize klass.rootKey()] = klass
    mappings
    

  defs loadData: (data) ->
    references = AS.Map.new()
    root = @rootKey()

    # TODO: implement runtime assertions
    # assert data[root], "loaded data for, but JSON had no data at rootKey: #{root}"

    modelData = data[root]
    modelData = convertKeys(modelData)
    
    [modelData, ids] = extractIds(modelData)
    model = @new(modelData)

    references.set(model, ids)

    for key, embeds of data
      continue if key is root
      # assert AS.Model.REST.mappings[key], "sideload data provided for #{key}, but no mapping exists in AS.Model.REST.mappings"
      @mappings()[key].sideloadData(embed, references) for embed in embeds

    references.each (model, ids) -> model.resolveReferences(ids)
    return model

  defs sideloadData: (modelData, references) ->
    modelData = convertKeys(modelData)
    [modelData, ids] = extractIds(modelData)
    model = @new(modelData)

    references.set(model, ids)

  def resolveReferences: (ids) ->
    for key, references of ids
      continue unless references
      
      relationKey = key.replace(/Id/, '')
      path = @[relationKey].model().path()
      
      if references.length is undefined
        id = references
        @[relationKey].set AS.All.byIdRef["#{id}-#{path}"]
      
      else
        for id in references
          @[relationKey].add AS.All.byIdRef["#{id}-#{path}"]

    