module "DOM"
test "creates document fragments", ->
  html = AS.DOM.new().html ->
    @head ->
      @title "This is the Title"
    @body ->
      @h1 "This is the Header"
      @section ->
        @p "I'm the body copy :D"
      @div "data-custom": "attributes!"

  equal $(html).find("title").text(), "This is the Title"
  equal $(html).find("h1").text(), "This is the Header"
  equal $(html).find("p").text(), "I'm the body copy :D"
  equal $(html).find("[data-custom]").data().custom, "attributes!"


test "appends raw (scary html) content", ->
  raw = AS.DOM.new().raw("<p>")
  ok $(raw).find("p").is("p")
  ok $(raw).is("span")

test "appends escaped (non-scary html) content", ->
  raw = AS.DOM.new().span -> @text("<html>")
  equal $(raw).find("html")[0], undefined
  