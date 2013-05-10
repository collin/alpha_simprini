class AS.Model.BlobAdapter < AS.Model.Adapter
  def initialize: ->
    @_super()
    @namespace = {}
    @comitted = Pathology.Set.new()
  
  def namedModel: (name, model) ->
    if model
      @namespace[name] = model.id
    else
      @namespace[name]

  def commit: (url, model, root, callback) ->
    return if model.committing?.get() is true
    @committing()
    $.ajax(type:'POST',url:url,dataType:'json').done (data) =>
      model.set id: data[root].id
      callback()
      @doneComitting()

  def autocommit: (url) ->
    @bind "update", _.throttle (=> @_autocommit(url)), 5000
    @bind "destroy", (model) => @destroy(url.replace "/blob", "")

  def destroy: (url) ->
    $.ajax(
      type: "DELETE"
      url: url
      contentType: "text/plain;charset=UTF-8"
    )

  def fetch: (url) ->
    $.getJSON(url).done (data) => @load(data)

  def _autocommit: (url) ->
    @committing()
    $.ajax(
      type:"POST"
      url: url
      data: JSON.stringify(@dump())
      contentType: "text/plain;charset=UTF-8"
    ).done => 
      @doneComitting()
      console.log "committed to #{url}"

  def committing: ->
    @registrations.each (model) ->
      model?.committing?.set(true)
    Taxi.Governer.exit()

  def doneComitting: ->
    @registrations.each (model) ->
      model?.committing?.set(false)
    Taxi.Governer.exit()

  def dump: ->
    objects = {}
  
    @registrations.each (model) ->
      return unless model?
      group = objects[model.constructor.path()] ?= {}
      group[model.id] = model.payload()

    return {
      namespace: @namespace,
      objectspace: objects
    }

  def load: ({namespace, objectspace}={}) ->
    if objectspace
      @sideload(objectspace)
      @resolveReferences(objectspace)
    @trigger("ready")
    