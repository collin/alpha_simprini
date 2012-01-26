AS = require("alpha_simprini")
_ = require "underscore"
jQuery = require "jQuery"

SVG =
  ns: "http://www.w3.org/2000/svg"

class AS.DOM
  @elements: _('a abbr address article aside audio b bdi bdo blockquote body button
    canvas caption cite code colgroup datalist dd del details dfn div dl dt em
    fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
    html i iframe ins kbd label legend li map mark menu meter nav noscript object
    ol optgroup option output p pre progress q rp rt ruby s samp script section
    select small span strong style sub summary sup table tbody td textarea tfoot
    th thead time title tr u ul video area base br col command embed hr img input
    keygen link meta paramsource track wbr
  '.split(" ")).chain().compact()

  @svg_elements = _('
    svg g defs desc title metadata symbol use switch image style path rect circle
    line ellipse polyline polygon text tspan tref textPath altGlyph altGlyphDef
    altGlyphItem glyphRef marker color-profile linearGradient radialGradient stop
    pattern clipPath mask filter feBlend feColorMatrix feComponentTransfer feComposite
    feConvolveMatrix feDiffuseLighting feDisplacementMap feFlood feGaussianBlur feImage
    feMerge feMergeNode feMorphology feOffset feSpecularLighting feTile feTurbulence
    feDistantLight fePointLight feSpotLight feFuncR feFuncG feFuncB feFuncA cursor a view
    script animate set animateMotion animateColor animateTransform mpath font font-face
    glyph missing-glyph hkern vkern font-face-src font-face-uri font-face-format
    font-face-name definition-src foreignObject
  '.split(" ")).chain().compact()

  constructor: (args) ->
    # body...

  $: jQuery

  text: (text_content) ->
    # createTextNode creates a text node, no DOM injection here
    # TODO: DOUBLE EXPRESS VERIFY THIS ASSUMPTION AND PASTE
    #   LINKS TO SUPPORTING EVIDENCE IN THE CODE.
    @current_node.appendChild document.createTextNode(text_content)

  raw: (html) ->
    @$(@span()).html(html)

  tag: (name, attrs, content) ->
    node = document.createElement(name)
    return @_tag node, attrs, content

  svg_tag: (name, attrs, content) ->
    node = document.createElementNS(SVG.ns, name)
    return @_tag node, attrs, content

  _tag: (node, attrs, content) ->
    @current_node ?= document.createDocumentFragment()
    if _.isFunction(attrs)
      content = attrs
      attrs = undefined
    if _.isString(attrs)
      text_content = attrs
      attrs = undefined

    # TODO: use jQuery for better compatibility / less performance
    for key, value of attrs || {}
      if @process_attr
        @process_attr(node, key, value)
      else
        node.setAttribute(key, value)

    @current_node.appendChild node

    if text_content
      @$(node).text text_content
    else if content
      @within_node node, ->
        last = content.call(this)
        if _.isString(last)
          @text(last)

    return node

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

AS.DOM.svg_elements.each (element) ->
  # Be wary of conflicts with regular HTML elements
  html_svg_conflict = ~AS.DOM.elements.value().indexOf(element)
  method_conflict = AS.DOM::[element]?
  if html_svg_conflict or method_conflict
    element = "svg_#{element}"

  AS.DOM::[element] = -> @svg_tag.apply this, _(arguments).unshift(element)

