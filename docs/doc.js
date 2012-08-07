(function() {
  var $, each;

  minispade.require("pathology");

  minispade.require("underscore");

  minispade.require("jquery");

  minispade.require("coffeekup");

  minispade.require("alpha_simprini");

  minispade.register("rangy-core", "rangy = null");

  minispade.register("jpicker", "null");

  AS.require("client");

  AS.require("css");

  $ = jQuery;

  each = _.each;

  jQuery(function() {
    var classdocs, classes;
    console.time("RENDER");
    classes = $("#classes");
    classdocs = $("#classdocs");
    each([Pathology.Object].concat(Pathology.Object.descendants), function(klass) {
      var classArticle, name, _i, _len, _ref;
      classes.append("<a href=\"#" + (klass.path()) + "\">" + (klass.path()) + "</a>");
      _ref = klass.instanceMethods || [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        if (klass.instanceMethod(name).definedOn !== klass.path()) continue;
        classes.append("<a href=\"#" + (klass.path()) + ".instanceMethod." + name + "\">#" + name + "</a>");
      }
      classArticle = function() {
        return article({
          id: this.klass.path()
        }, function() {
          h1(this.klass.path());
          h2("Ancestors");
          nav({
            "class": 'ancestors'
          }, function() {
            var ancestor, index, _j, _len2, _len3, _ref2, _ref3, _results;
            _ref2 = this.klass.ancestors.slice(0, -1);
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              ancestor = _ref2[_j];
              if (ancestor === this.klass) continue;
              a({
                href: "#" + (ancestor.path())
              }, function() {
                return ancestor.path();
              });
              text(" < ");
            }
            _ref3 = this.klass.ancestors.slice(-1);
            _results = [];
            for (index = 0, _len3 = _ref3.length; index < _len3; index++) {
              ancestor = _ref3[index];
              _results.push(a({
                href: "#" + (ancestor.path())
              }, function() {
                return ancestor.path();
              }));
            }
            return _results;
          });
          h2("Class Methods");
          ul(function() {
            var method, name, _j, _len2, _ref2, _results;
            _ref2 = this.klass.classMethods || [];
            _results = [];
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              name = _ref2[_j];
              if (!(method = this.klass.classMethod(name))) continue;
              _results.push(li({
                id: this.klass.path() + ".classMethod." + name
              }, function() {
                h1(method.name);
                span({
                  "class": "private"
                }, function() {
                  if (method.private) return "private api";
                });
                a({
                  href: "#" + method.definedOn
                }, function() {
                  return "defined on: " + method.definedOn;
                });
                return pre(h(method.desc) || "No Description Given");
              }));
            }
            return _results;
          });
          h2("Instance Methods");
          return ul(function() {
            var method, name, _j, _len2, _ref2, _results;
            _ref2 = this.klass.instanceMethods || [];
            _results = [];
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              name = _ref2[_j];
              if (!(method = this.klass.instanceMethod(name))) continue;
              _results.push(li({
                id: this.klass.path() + ".instanceMethod." + name
              }, function() {
                h1(method.name);
                span({
                  "class": "private"
                }, function() {
                  if (method.private) return "private api";
                });
                a({
                  href: "#" + method.definedOn
                }, function() {
                  return "defined on: " + method.definedOn;
                });
                return pre(h(method.desc) || "No Description Given");
              }));
            }
            return _results;
          });
        });
      };
      return classdocs.append(CoffeeKup.render(classArticle, {
        klass: klass,
        hardcode: {
          each: each
        }
      }));
    });
    return console.timeEnd("RENDER");
  });

}).call(this);
