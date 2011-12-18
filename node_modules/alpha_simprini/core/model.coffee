AS = require("alpha_simprini")
AS.All =
  byId: {}
  byCid: {}
    
class AS.Model
  AS.Event.extends(this)
  AS.InheritableAttrs.extends(this)
  AS.Callbacks.extends(this)
    
  @define_callbacks(after: ["initialize"], before: ["initialize", "open"])
    
  @embeds_many: (name, config) ->
    config.relation = true
    @relation(name)
    @attribute(name)
    @write_inheritable_value("embeds_manys", name, config)

  @has_many: (name, config={}) ->
    config.relation = true
    @relation(name)
    @attribute(name)
    @write_inheritable_value("has_manys", name, config)

  @embeds_one: (name, config={}) ->
    config.relation = true
    @relation(name)
    @write_inheritable_value("embeds_ones", name, config)
      
    @::[name] = (value) ->
      if value is undefined
        AS.All.byCid[@get_attribute(name)]
      else
        if value is null
          @set_attribute(name, undefined)
        else if value.cid
          @set_attribute(name, value.cid)
        else if _.isString(value)
          @set_attribute(name, value)
        else
          if value._type
            model = module(value._type)
          else
            model = AS.Model
          @set_attribute name, (new model value).cid
    
  @has_one: (name, config={}) ->
    config.relation = true
    @relation(name)
    @write_inheritable_value("has_ones", name, config)
      
    @::[name] = (value) ->
      if value is undefined
        AS.All.byCid[@get_attribute(name)]
      else
        if value is null
          @set_attribute(name, undefined)
        else if value.cid
          @set_attribute(name, value.cid)
        else if _.isString(value)
          @set_attribute(name, value)
        else
          if value._type
            model = module(value._type)
          else
            model = AS.Model
          @set_attribute name, (new model value).cid
  
  @belongs_to: (name, config={}) ->
    config.relation = true
    @relation(name)
    @write_inheritable_value("belongs_tos", name, config)
    
    @::[name] = (value) ->
      if value is undefined
        AS.All.byCid[@get_attribute(name)]
      else
        if value is null
          @set_attribute(name, undefined)
        else if value.cid
          @set_attribute(name, value.cid)
        else if _.isString(value)
          @set_attribute(name, value)
        else
          throw new Error(["Cannot set #{name} to unexpected value. Try passing a cid, or an object with a cid. Value was: ", value])
  
  @relation: (name) ->
    @push_inheritable_item("relations", name)
  
  @field: (name, config={}) ->
    @write_inheritable_value("fields", name, config)
    @attribute(name)
    
  @attribute: (name) ->
    @::[name] = (value, options) ->
      if value is undefined
        @get_attribute(name)
      else
        @set_attribute(name, value, options)
    
  @initialize_relations: (model)  ->
    
  constructor: (@attributes = {}, options={}) ->        
    @run_callbacks "before_initialize"
    @initialize(options)
    @run_callbacks "after_initialize"
  
  initialize: (options={}) ->
    @attributes.id ?= AS.uniq()
      
    @previous_attributes = @attributes
    @id = @attributes.id
    @cid = @id or _.uniqueId("c")
    
    AS.All.byCid[@cid] = AS.All.byId[@id] = this
      
    @initialize_embeds_many(name, config) for name, config of @constructor.embeds_manys || {}
    @initialize_has_many(name, config) for name, config of @constructor.has_manys || {}
    @initialize_embeds_one(name, config) for name, config of @constructor.embeds_ones || {}
    @initialize_has_one(name, config) for name, config of @constructor.has_ones || {}
    @initialize_belongs_to(name, config) for name, config of @constructor.belongs_tos || {}

  last: (attr) -> 
    [@attributes, @previous_attributes] = [@previous_attributes, @attributes]
    last = @[attr]()
    [@attributes, @previous_attributes] = [@previous_attributes, @attributes]
    last

  initialize_embeds_many: (name, config) ->
    data = {}
    klass = class this["#{name}_collection_klass"] extends AS.EmbeddedCollection
    _.extend klass::, config
    klass.model = -> config.model() if config.model
    collection = data[name] = new klass(@[name]?())
    collection.source = this
    @set data
    
  initialize_has_many: (name, config) ->
    @has_manys ||= {}
    data = {}
    klass = class this["#{name}_collection_klass"] extends AS.Collection
    _.extend klass::, config
    klass.model = -> config.model() if config.model
    @has_manys[name] = collection = data[name] = new klass()
    collection.source = this
    @set data
    
  initialize_embeds_one: (name, config) ->
    unless @[name](@attributes[name])
      @[name]( new (config.model()) )
    
  initialize_has_one: (name, config) ->
    @[name](@attributes[name])
    
  initialize_belongs_to: (name, config) ->
    # pass; not sure you have to do anything, this should be properly set already.
  
  save: () ->
    return false unless @changed()
    @persist()
    true

  # Persisted is a callback here.
  # Actual persistance will be handled by an observer. DEAL WITH IT IF YOU WANT IT.
  persisted: ->
    @previous_attributes = @attributes
  
  changes: () ->
    changed = {}
    for key, value of @attributes
      changed[key] = value unless @previous_attributes[value] is value
    changed
  
  # Blessed be backbone
  changed: () -> _(@changes).chain().keys().any().value()
  
  get: (attr) -> @[attr]()
  
  set: (attrs) ->
    @[key](value) for key, value of attrs
      
  set_attribute: (name, value, options={}) ->
    @attributes[name] = value
    @trigger("change:#{name}", name, value, options)
    @trigger("change", name, value, options)
    value
    
  get_attribute: (name) ->
    @attributes?[name]
  
  destroy: () ->
    @trigger("destroy")
  
  trigger: () ->
    args =  [].concat.apply [], arguments
    args.splice 1, 0, this
    AS.Event.instance_methods.trigger.apply this, args
            
            