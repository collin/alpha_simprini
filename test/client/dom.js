(function() {

  module("DOM");

  test("creates document fragments", function() {
    var html;
    html = AS.DOM["new"]().html(function() {
      this.head(function() {
        return this.title("This is the Title");
      });
      return this.body(function() {
        this.h1("This is the Header");
        this.section(function() {
          return this.p("I'm the body copy :D");
        });
        return this.div({
          "data-custom": "attributes!"
        });
      });
    });
    equal($(html).find("title").text(), "This is the Title");
    equal($(html).find("h1").text(), "This is the Header");
    equal($(html).find("p").text(), "I'm the body copy :D");
    return equal($(html).find("[data-custom]").data().custom, "attributes!");
  });

  test("appends raw (scary html) content", function() {
    var raw;
    raw = AS.DOM["new"]().raw("<p>");
    ok($(raw).find("p").is("p"));
    return ok($(raw).is("span"));
  });

  test("appends escaped (non-scary html) content", function() {
    var raw;
    raw = AS.DOM["new"]().span(function() {
      return this.text("<html>");
    });
    return equal($(raw).find("html")[0], void 0);
  });

}).call(this);
