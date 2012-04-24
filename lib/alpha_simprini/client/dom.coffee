AS = require("alpha_simprini")
_ = require "underscore"
$ = require "jquery"

SVG =
  ns: "http://www.w3.org/2000/svg"

DOM_ELEMENTS = _('a abbr address article aside audio b bdi bdo blockquote body button
  canvas caption cite code colgroup datalist dd del details dfn div dl dt em
  fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
  html i iframe ins kbd label legend li map mark menu meter nav noscript object
  ol optgroup option output p pre progress q rp rt ruby s samp script section
  select small span strong style sub summary sup table tbody td textarea tfoot
  th thead time title tr u ul video area base br col command embed hr img input
  keygen link meta paramsource track wbr
'.split(" ")).chain().compact()

SVG_ELEMENTS = _('
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

AS.DOM = AS.Object.extend ({delegate, include, def, defs}) ->
  def $: $

  def text: (textContent) ->
    # createTextNode creates a text node, no DOM injection here
    # TODO: DOUBLE EXPRESS VERIFY THIS ASSUMPTION AND PASTE
    #   LINKS TO SUPPORTING EVIDENCE IN THE CODE.
    @currentNode.appendChild document.createTextNode(textContent)

  def raw: (html) ->
    @$(@span()).html(html)

  def tag: (name, attrs, content) ->
    node = document.createElement(name)
    return @_tag node, attrs, content

  def svgTag: (name, attrs, content) ->
    node = document.createElementNS(SVG.ns, name)
    return @_tag node, attrs, content

  def _tag: (node, attrs, content) ->
    @currentNode ?= document.createDocumentFragment()
    if _.isFunction(attrs)
      content = attrs
      attrs = undefined
    if _.isString(attrs)
      textContent = attrs
      attrs = undefined

    # TODO: use jQuery for better compatibility / less performance
    for key, value of attrs || {}
      if @process_attr
        @process_attr(node, key, value)
      else
        node.setAttribute(key, value)

    @currentNode.appendChild node

    if textContent
      @$(node).text textContent
    else if content
      @withinNode node, ->
        last = content.call(this)
        @text(last) if _.isString(last)

    return node

  def withinNode: (node, fn) ->
    node = node[0] if node?.jquery
    priorNode = @currentNode
    @currentNode = node
    content = fn.call(this)
    @currentNode = priorNode
    content

  def danglingContent: (fn) -> @withinNode(null, fn)

DOM_ELEMENTS.each (element) ->
  AS.DOM::[element] = -> @tag.apply this, _(arguments).unshift(element)

SVG_ELEMENTS.each (element) ->
  # Be wary of conflicts with regular HTML elements
  htmlSvgConflict = ~DOM_ELEMENTS.value().indexOf(element)
  methodConflict = AS.DOM::[element]?
  if htmlSvgConflict or methodConflict
    safeElement = "svg_#{element}"

  AS.DOM::[safeElement or element] = -> @svgTag.apply this, _(arguments).unshift(element)

