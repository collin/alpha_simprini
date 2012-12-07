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
      var classArticle, name, _i, _j, _len, _len2, _ref, _ref2, _ref3;
      classes.append("<a href=\"#" + (klass.path()) + "\">" + (klass.path()) + "</a>");
      _ref = klass.instanceMethods || [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        if (klass.instanceMethod(name).definedOn !== klass.path()) continue;
        classes.append("<a class=\"method\" href=\"#" + (klass.path()) + ".instanceMethod." + name + "\">#" + name + "</a>");
      }
      _ref2 = klass.classMethods || [];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        name = _ref2[_j];
        if (klass === Pathology.Object) continue;
        if (((_ref3 = klass.classMethod(name)) != null ? _ref3.definedOn : void 0) !== klass.path()) {
          continue;
        }
        classes.append("<a class=\"method\" href=\"#" + (klass.path()) + ".classMethod." + name + "\">" + name + "</a>");
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
            var ancestor, index, _k, _len3, _len4, _ref4, _ref5, _results;
            _ref4 = this.klass.ancestors.slice(0, -1);
            for (_k = 0, _len3 = _ref4.length; _k < _len3; _k++) {
              ancestor = _ref4[_k];
              if (ancestor === this.klass) continue;
              a({
                href: "#" + (ancestor.path())
              }, function() {
                return ancestor.path();
              });
              text(" < ");
            }
            _ref5 = this.klass.ancestors.slice(-1);
            _results = [];
            for (index = 0, _len4 = _ref5.length; index < _len4; index++) {
              ancestor = _ref5[index];
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
            var method, name, _k, _len3, _ref4, _results;
            _ref4 = this.klass.classMethods || [];
            _results = [];
            for (_k = 0, _len3 = _ref4.length; _k < _len3; _k++) {
              name = _ref4[_k];
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
            var method, name, _k, _len3, _ref4, _results;
            _ref4 = this.klass.instanceMethods || [];
            _results = [];
            for (_k = 0, _len3 = _ref4.length; _k < _len3; _k++) {
              name = _ref4[_k];
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
