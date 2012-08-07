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
      var classArticle;
      classes.append("<a href=\"#" + (klass.path()) + "\">" + (klass.path()) + "</a>");
      classArticle = function() {
        return article({
          id: this.klass.path()
        }, function() {
          h1(this.klass.path());
          h2("Ancestors");
          nav({
            "class": 'ancestors'
          }, function() {
            var ancestor, index, _len, _ref, _results;
            _ref = this.klass.ancestors;
            _results = [];
            for (index = 0, _len = _ref.length; index < _len; index++) {
              ancestor = _ref[index];
              if (ancestor === this.klass) continue;
              a({
                href: "#" + (ancestor.path())
              }, function() {
                return ancestor.path();
              });
              if (index !== this.klass.ancestors.length - 1) {
                _results.push(text(" < "));
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          });
          h2("Class Methods");
          ul(function() {
            var method, name, _i, _len, _ref, _results;
            _ref = this.klass.classMethods || [];
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              name = _ref[_i];
              if (!(method = this.klass.classMethod(name))) continue;
              if (method.definedOn !== this.klass.path()) continue;
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
            var method, name, _i, _len, _ref, _results;
            _ref = this.klass.instanceMethods || [];
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              name = _ref[_i];
              if (!(method = this.klass.instanceMethod(name))) continue;
              if (method.definedOn !== this.klass.path()) continue;
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
