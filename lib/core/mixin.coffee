# BITCHIN SWEET CoffeeScript/_ Mixin capability
AS = require("alpha_simprini")
_ = require "underscore"

class AS.Mixin
  extended: (klass) ->
    _(klass.extended_by || klass.constructor.extended_by).include(this)
      
  extends: (klass) ->
    # Bails out if already extended (no double extensions here)
    klass.extended_by ?= []
    # Clone it so subclass extensions don't pollute
    # their parents and siblings.
    klass.extended_by = _.clone(klass.extended_by)
    return if this in klass.extended_by
    klass.extended_by.push this
    
    _.extend klass, @class_methods if @class_methods
    _.extend klass::, @instance_methods if @instance_methods
      
    @depend_on(it, klass) for it in @depends_on if @depends_on
    @mixed_in.call(klass) if @mixed_in

  constructor: (methods) ->
    _.extend this, methods
    
  depend_on: (it, klass) ->
    it.extends(klass)
