AS = require("alpha_simprini")
_ = require "underscore"
jwerty = require("jwerty").jwerty
domready = require("jQuery").ready

class AS.Application
  AS.Event.extends(this)

  constructor: (args) ->
    @template_source = @template_source()
    for name, template of @template_source
      @template_source[name] = CoffeeKup.compile(template, locals:yes, hardcode:AS.TemplateHelpers)
      
    domready => 
      @params = AS.params
      @god_given_key_handlers()
      @initialize?()
    
  god_given_key_handlers: ->
    jwerty.key 'esc', => @trigger("esc")
    
  template_source: -> @Templates

  view: (constructor, options={}) ->
    options.application = this
    new constructor options

  render: (template_name, locals={}) ->
    data = {context: this, locals:locals}
    @template_source[template_name](data)
    
  append: (view) ->
    @el.append view.el
    
    