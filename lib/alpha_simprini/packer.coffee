module "AS.Heap", ->
  @CLASS = 0x11
  @ATTRIBUTES = 0x12
  @CLASSES = 0x13
  @OBJECTS = 0x14
  @NAMED_OBJECTS = 0x15
  @LITERALS = 0x16
  
  class @NullClass
    constructor: ->
  
  @Classes =
    PackedClass: Function
    Array: Array
    Numeric: Number
    Fixnum: Number
    String: String
    Symbol: String
    Hash: Object
    NilClass: null
    FalseClass: false
    TrueClass: true
    
  class @Unpacker
    constructor: (hash) ->
      @literals = hash[AS.Heap.LITERALS]
      @classes = {}
      
      for key, value of hash[AS.Heap.CLASSES]
        @classes[value] = @resolve_class(key)
          
      @packed_objects = hash[AS.Heap.OBJECTS]
      @objects = {}
      @named_objects = {} 
      
      @unpack_object(key) for key, value of @packed_objects
        
      for key, value of hash[AS.Heap.NAMED_OBJECTS]
        @named_objects[@unpack_object(key)] = @unpack_object(value)

    resolve_class: (key) ->
      unless (klass = AS.Heap.Classes[key]) is undefined
        klass
      else
        throw new Error("Unresolved class with key #{key}")
      

    allocate_object: (klass) ->
        eval("function #{klass.name} () {this.constructor = klass; }")
        ctor = eval klass.name
        ctor.prototype = klass.prototype
        ctor.__super__ = klass.__super__
        object = new ctor

    unpack_object: (key) ->
      return @objects[key] if @objects[key]
      value = @packed_objects[key]
      attributes = value[AS.Heap.ATTRIBUTES]
      klass = @classes[value[AS.Heap.CLASS]]
      if klass == Object
        object = @objects[key] = {}
        for _key, _value of attributes
          object[@unpack_object(_key)] = @unpack_object(_value)
        object
      # else if klass == Function
        # console.log "FUCTIONCLASS", klass, @unpack_object(value)
      else if klass == Array
        @objects[key] = @unpack_object(item) for item in attributes
      else if klass == Number
        @objects[key] = @literals[attributes]
      else if klass == String
        @objects[key] = @literals[attributes]
      else if klass == null
        @objects[key] = null
      else if klass == true
       @objects[key] = true
      else if klass == false
        @objects[key] = false
      else
        object = @objects[key] = @allocate_object(klass)
        for _key, _value of attributes
          object[@unpack_object(_key).replace(/^@/, '')] = @unpack_object(_value)
        object

# FIXME: TESTCASE
# class ThingClass
# 
#   constructor: (@ace, @b, @c, @t) ->
#   
# AS.Heap.Classes.Thing = ThingClass
# 
# window.d = {"19":{"Thing":0,"Symbol":1,"String":2,"Array":3,"NilClass":4,"Fixnum":5,"Numeric":6},"20":{"70175767968160":{"17":0,"18":{"677308":70175767963660,"677468":70175767968120,"677628":247,"677788":70175767968160}},"677308":{"17":2,"18":0},"70175767963660":{"17":3,"18":[70175767968100,70175767968060,70175767968020,70175767967980,70175767967940,70175767967900,70175767967860,70175767967820,70175767967780,70175767967740,70175767967700,70175767967660,70175767967620,70175767967580,70175767967540,70175767967500,70175767967460,70175767967420,70175767967380,70175767967340,70175767967300,70175767967260,70175767967220,70175767967180,70175767967140,70175767967100,70175767967060,70175767967020,70175767966980,70175767966940,70175767966900,70175767966860,70175767966820,70175767966780,70175767966740,70175767966700,70175767966660,70175767966620,70175767966580,70175767966540,70175767966500,70175767966460,70175767966420,70175767966380,70175767966340,70175767966300,70175767966260,70175767966220,70175767966180,70175767966140,70175767966100,70175767966060,70175767966020,70175767965980,70175767965940,70175767965900,70175767965860,70175767965820,70175767965780,70175767965740,70175767965700,70175767965660,70175767965620,70175767965580,70175767965540,70175767965500,70175767965460,70175767965420,70175767965380,70175767965340,70175767965300,70175767965260,70175767965220,70175767965180,70175767965140,70175767965100,70175767965060,70175767965020,70175767964980,70175767964940,70175767964900,70175767964860,70175767964820,70175767964780,70175767964740,70175767964700,70175767964660,70175767964620,70175767964580,70175767964540,70175767964500,70175767964460,70175767964420,70175767964380,70175767964340,70175767964300,70175767964260,70175767964220,70175767964180,70175767964140,70175767964100,70175767964060,70175767964020,70175767963980,70175767963940,70175767963900,70175767963860,70175767963820,70175767963780,70175767963740,70175767963700]},"70175767968100":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"4":{"17":4,"18":{}},"677468":{"17":2,"18":1},"677628":{"17":2,"18":2},"677788":{"17":2,"18":3},"70175767968060":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767968020":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967980":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967940":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967900":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967860":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967820":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967780":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967740":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967700":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967660":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967620":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967580":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967540":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967500":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967460":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967420":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967380":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967340":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967300":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967260":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967220":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967180":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967140":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967100":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967060":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767967020":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966980":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966940":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966900":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966860":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966820":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966780":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966740":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966700":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966660":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966620":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966580":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966540":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966500":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966460":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966420":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966380":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966340":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966300":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966260":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966220":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966180":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966140":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966100":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966060":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767966020":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965980":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965940":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965900":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965860":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965820":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965780":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965740":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965700":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965660":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965620":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965580":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965540":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965500":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965460":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965420":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965380":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965340":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965300":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965260":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965220":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965180":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965140":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965100":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965060":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767965020":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964980":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964940":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964900":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964860":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964820":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964780":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964740":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964700":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964660":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964620":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964580":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964540":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964500":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964460":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964420":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964380":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964340":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964300":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964260":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964220":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964180":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964140":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964100":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964060":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767964020":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767963980":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767963940":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767963900":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767963860":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767963820":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767963780":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767963740":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767963700":{"17":0,"18":{"677308":4,"677468":4,"677628":4,"677788":4}},"70175767968120":{"17":2,"18":4},"247":{"17":6,"18":5},"70175767963520":{"17":2,"18":6}},"21":{"70175767963520":70175767968160},"22":["@ace","@b","@c","@t","OMGt,t,t,t,t,t,t,t,t,t,t,tt,t,t,t,t,t,t,t,t,t,t,tt,t,t,t,t,t,t,t,t,t,t,tt,t,t,t,t,t,t,t,t,t,t,tt,t,t,t,t,t,t,t,t,t,t,t",123,"thing"]}
# window.up=new AS.Heap.Unpacker(d)