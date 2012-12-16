domready = jQuery
{defer} = _
require("jwerty")

class AS.Application
  include Taxi.Mixin

  def initialize: (config={}) ->
    _.extend(this, config)
    @stateObjects = {}
    @params = AS.params

    @keyRouter = AS.KeyRouter.new(this, document.body)
  # @::initialize.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #     Initializes the Application object. Setting up a ZoneController, 
  #     states objects, and view objects.
  #   """

  JQUERY_EVENTS = """
    bind blur change click dblclick focus focusin focusout 
    keydown keypress keyup load mousedown mousenter mouseleave mousemove 
    mouseout mouseover mouseup ready resize scroll select submit load unload
    mousewheel
  """
  def applyTo: (element) ->
    @el = $(element)

    _document = window.parent.document
    for event in JQUERY_EVENTS.split(/\s+/)
      continue if event.match(/^\s+$/)
      jQuery(_document).on "#{event}.runloop", -> 
        defer -> Taxi.Governer.exit() if Taxi.Governer.currentLoop
  
    jQuery(_document).ajaxSend ->
      Taxi.Governer.exit() if Taxi.Governer.currentLoop  

    jQuery(_document).ajaxComplete ->
      Taxi.Governer.exit() if Taxi.Governer.currentLoop

    # FIXME: don't do this on applyTo
    #   would rather them happen on load, not on application
    @connect()
    @buildState()
    @content()

    AS.unbindGoverner = -> $(_document).unbind(".runloop")

  def connect: ->
    
  # @::connect.doc = 
  #   desc: """
  #     Override the connect method to instantiate to storage/connection adapters
  #   """

  def buildState: ->
    @state 'zoneController', AS.Models.ZoneController.new(application: this)
    @state 'appZones', @zoneController.defaultZoneGroup.get()
  # @::buildState.doc = 
  #   desc: """
  #     Override this method to build your application state objects.
  #   """

  def content: ->
  # @::content.doc = 
  #   desc: """
  #     Override this method to build your application view objects.
  #   """

  def prepareModel: (id, _model) ->
    path = _model.constructor.path()
    _constructor = AS.loadPath(path)
    model = _constructor.prepare(id: id, application: this)
    # console.log "[preparedModel] #{model.toString()}, #{model.id}" 
  # @::prepareModel.doc = 
  #   params: [
  #     ["id", [String], true]
  #     ["model", AS.Model, true]
  #   ]
  #   desc: """
  #     Prepare a model with the same id and constructor path
  #     as another model. Used when cutting over applications
  #     to an updated code base.
  #   """

  def takeOverModel: (id, _model) ->
    path = _model.constructor.path()
    constructor = AS.loadPath(path)
    model = constructor.find(id)
    model.takeOver(_model)
  # @::takeOverModel.doc = 
  #   params: [
  #     ["id", String, true, tag: "The id of the model to take over"]
  #     ["_model", AS.Model, true, tag: "The corresponding model to take over."]
  #   ]
  #   desc: """
  #     Take over the properties of another model. Used to cut over applicatons
  #     to an updated code base.
  #   """

  def takeOverState: (application) ->
    for key, value of application.stateObjects
      # console.log "[takeOverState] #{key} => #{value.toString()}", value.id
      @stateObjects[key] = @[key] = AS.Model.find(value.id)
  # @::takeOverState.doc = 
  #   params: [
  #     ["application", AS.Application, true, tag:"The application to take over."]
  #   ]
  #   desc: """
  #     Take aver the state objects of another application. Used when cutting over.
  #   """

  def state: (name, _constructor, options...) ->
    return if @[name]?

    stateObject = if _constructor.new
      _constructor.new.apply(_constructor, options)
    else
      _constructor

    @[name] = @stateObjects[name] = stateObject
  # @::state.doc = 
  #   desc: """
  #     Creates a state object in the application.
  #   """

  def view: (_constructor, options={}) ->
    options.application = this
    _constructor.new options
  # @::view.doc =
  #   desc: """
  #     Creates a view in the application.
  #   """

  def zone: (name) ->
    @appZones.add -> @object.application[name]
  # @::zone.doc = 
  #   params: [
  #     ["name", String, true, 
  #       tag: """
  #             The name of a view in the application that will act as 
  #              a navigation zone
  #           """]
  #   ]
  #   desc: """
  #     Add a zone to the main application zone group. Lookup of application
  #     zones is extremely late-bound, so they must be referenced by name only.
  #     this is because zone state
  #   """

  def append: (view) ->
    @el.append view.el
  # @::append.doc =
  #   desc: """
  #     Append a view's element to the application element.
  #   """

