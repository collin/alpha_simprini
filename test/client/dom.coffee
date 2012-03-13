{AS, $, _, sinon} = require require("path").resolve("./test/client_helper")
exports.DOM =
  "creates document fragments": (test) ->
    html = AS.DOM.new().html ->
      @head ->
        @title "This is the Title"
      @body ->
        @h1 "This is the Header"
        @section ->
          @p "I'm the body copy :D"
        @div "data-custom": "attributes!"

    test.equal $(html).find("title").text(), "This is the Title"
    test.equal $(html).find("h1").text(), "This is the Header"
    test.equal $(html).find("p").text(), "I'm the body copy :D"
    test.equal $(html).find("[data-custom]").data().custom, "attributes!"

    test.done()

  "appends raw (scary html) content": (test) ->
    raw = AS.DOM.new().raw("<html>")
    test.ok $(raw).find("html").is("html")
    test.done()

  "appends escaped (non-scary html) content": (test)->
    raw = AS.DOM.new().span -> @text("<html>")
    test.equal $(raw).find("html")[0], undefined
    test.done()
