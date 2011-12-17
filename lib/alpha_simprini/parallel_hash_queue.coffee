class module("AS").ParallelHashQueue
  AS.Event.extends(this)
  
  initialize: (hash, fn) ->
    @count = _(hash).keys().length
    @loaded = 0
    
    return @trigger("complete") if @total is 0
    
    callback = fn (key) =>
      @loaded++
      @trigger("complete:#{key}", @loaded, @count)
      if @count is @loaded
        @trigger("complete")
    
    fn(key, value, callback) for key, value of hash
        
      
    
    