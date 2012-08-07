minispade.require "pathology"
minispade.require "underscore"
minispade.require "jquery"
minispade.require "coffeekup"
minispade.require "alpha_simprini"
minispade.register "rangy-core", "rangy = null"
minispade.register "jpicker", "null"

AS.require("client")
AS.require("css")

$ = jQuery
{each} = _


jQuery ->
  console.time("RENDER")
  classes = $("#classes")
  classdocs = $("#classdocs")
  each [Pathology.Object].concat(Pathology.Object.descendants), (klass) ->
    classes.append """
      <a href="##{klass.path()}">#{klass.path()}</a>
    """

    classArticle = -> article id: @klass.path(), ->
      h1 @klass.path()

      h2 "Ancestors"
      nav class:'ancestors', ->
        for ancestor, index in @klass.ancestors
          continue if ancestor is @klass
          a href:"##{ancestor.path()}", -> ancestor.path()
          text " < " unless index is @klass.ancestors.length - 1


      h2 "Class Methods"
      ul ->
        for name in @klass.classMethods or []
          continue unless method = @klass.classMethod(name)
          continue unless method.definedOn is @klass.path()
          li id: @klass.path() + ".classMethod." + name, ->
            h1 method.name
            span class:"private", -> "private api" if method.private
            a href:"##{method.definedOn}", ->
              "defined on: " + method.definedOn
            pre h(method.desc) or "No Description Given"

      h2 "Instance Methods"
      ul ->
        for name in @klass.instanceMethods or []
          continue unless method = @klass.instanceMethod(name)
          continue unless method.definedOn is @klass.path()
          li id: @klass.path() + ".instanceMethod." + name, ->
            h1 method.name
            span class:"private", -> "private api" if method.private
            a href:"##{method.definedOn}", ->
              "defined on: " + method.definedOn
            pre h(method.desc) or "No Description Given"

    classdocs.append CoffeeKup.render classArticle, klass:klass, hardcode: {each}
  console.timeEnd("RENDER")