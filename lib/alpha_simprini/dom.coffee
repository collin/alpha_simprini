AS = require("alpha_simprini")
_ = require "underscore"
console.warn "DEBUG CODE IN PLACE"

class AS.DOM
  @elements: _('a abbr address article aside audio b bdi bdo blockquote body button
    canvas caption cite code colgroup datalist dd del details dfn div dl dt em
    fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
    html i iframe ins kbd label legend li map mark menu meter nav noscript object
    ol optgroup option output p pre progress q rp rt ruby s samp script section
    select small span strong style sub summary sup table tbody td textarea tfoot
    th thead time title tr u ul video area base br col command embed hr img input keygen link meta param
    source track wbr'.split(" ")).chain().compact()
  
  constructor: (args) ->
    # body...

  text: (text_content) ->
    console.warn "FIXME: escape text content!"
    @current_node.appendChild document.createTextNode(text_content)
  
  raw: (html) ->
    $(@span()).html(html)
  
  tag: (name, attrs, content) ->
    @current_node ?= document.createDocumentFragment()
    if _.isFunction(attrs)
      content = attrs
      attrs = undefined
    if _.isString(attrs)
      text_content = attrs
      attrs = undefined
  
    # TODO: use jQuery for better compatibility / less performance
    node = document.createElement(name)
    for key, value of attrs || {}
      if @process_attr
        @process_attr(node, key, value)
      else
        node.setAttribute(key, value)
  
    @current_node.appendChild node
  
    if text_content
      $(node).text text_content
    else if content
      @within_node node, ->
        if window.location.href.match(/debug$/)
          try
            last = content.call(this)
            if _.isString(last)
              @text(last)
          catch error
            AS.error error, node
            @raw "<span class='error'>ERROR #{error.type}</span>" 
        else
          last = content.call(this)
          if _.isString(last)
            @text(last)
          
    node
  
  within_node: (node, fn) ->
    node = node[0] if node?.jquery
    prior_node = @current_node
    @current_node = node
    content = fn.call(this)
    @current_node = prior_node
    content
  
  dangling_content: (fn) -> @within_node(null, fn)
  
AS.DOM.elements.each (element) ->
  AS.DOM::[element] = -> @tag.apply this, _(arguments).unshift(element)
