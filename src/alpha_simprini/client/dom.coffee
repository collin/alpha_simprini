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


class AS.DOM
  def $: $

  def _document: document

  def text: (textContent) ->
    # createTextNode creates a text node, no DOM injection here
    # TODO: DOUBLE EXPRESS VERIFY THIS ASSUMPTION AND PASTE
    #   LINKS TO SUPPORTING EVIDENCE IN THE CODE.
    textNode = @_document.createTextNode(textContent)
    if @currentNode
      @currentNode.appendChild textNode
    else
      textNode
  # @::text.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def raw: (html) ->
    @$(@span()).html(html)
  # @::raw.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def tag: (name, attrs, content) ->
    node = @_document.createElement(name)
    return @_tag node, attrs, content
  # @::tag.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def svgTag: (name, attrs, content) ->
    node = @_document.createElementNS(SVG.ns, name)
    return @_tag node, attrs, content
  # @::svgTag.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def _tag: (node, attrs, content) ->
    @currentNode ?= @_document.createDocumentFragment()
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
  # @::_tag.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def withinNode: (node, fn) ->
    node = node[0] if node?.jquery
    priorNode = @currentNode
    @currentNode = node
    content = fn.call(this)
    @currentNode = priorNode
    content
  # @::withinNode.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

  def danglingContent: (fn) -> @withinNode(null, fn)
  # @::danglingContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

DOM_ELEMENTS.each (element) ->
  definition = {}
  definition[element] = -> @tag.apply this, _(arguments).unshift(element)
  AS.DOM.def definition
  # AS.DOM::[element].doc = 
  #   params: [
  #   ]
  #   desc: """
  #     HTML <#{element}> element.
  #   """

SVG_ELEMENTS.each (element) ->
  # Be wary of conflicts with regular HTML elements
  htmlSvgConflict = ~DOM_ELEMENTS.value().indexOf(element)
  methodConflict = AS.DOM::[element]?
  if htmlSvgConflict or methodConflict
    safeElement = "svg_#{element}"

  definition = {}
  definition[safeElement or element] = -> @svgTag.apply this, _(arguments).unshift(element)
  AS.DOM.def definition
  # AS.DOM::[safeElement or element].doc = 
  #   params: [
  #   ]
  #   desc: """
  #     SVG <#{element}> element.
  #   """


