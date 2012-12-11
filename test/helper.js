(function() {
  var BoundModel, NS, SimpleModel;

  minispade.require("alpha_simprini");

  minispade.require("jquery");

  minispade.require("jwerty");

  minispade.require("underscore");

  NS = window.NS = AS.Namespace["new"]("NS");

  AS.require("core");

  AS.require("client");

  AS.part("Core").require("model/share");

  window.QUnit.testStart = function(_arg) {
    var module, name;
    module = _arg.module, name = _arg.name;
    if (QUnit.urlParams.debug) {
      console.info("testSteart: " + module + " - " + name);
    }
    if (Taxi.Governer.currentLoop) Taxi.Governer.exit();
    return AS.All = {
      byCid: {},
      byId: {},
      byIdRef: {}
    };
  };

  BoundModel = NS.BoundModel = AS.Model.extend(function(_arg) {
    var def, defs, delegate, include;
    delegate = _arg.delegate, include = _arg.include, def = _arg.def, defs = _arg.defs;
    this.field("field");
    this.field("maybe", {
      type: AS.Model.Boolean
    });
    this.hasMany("items", {
      model: function() {
        return SimpleModel;
      }
    });
    return this.hasOne("owner");
  });

  SimpleModel = NS.SimpleModel = NS.SimpleModel = AS.Model.extend();

  SimpleModel.field("field");

  NS.mockBinding = function(binding_class, _options) {
    var binding, context, field, fn, mocks, model, options;
    if (_options == null) _options = {};
    context = _options.context || AS.View["new"]();
    model = _options.model || BoundModel["new"]({
      field: "value"
    });
    field = _options.field || model["field"];
    options = _options.options || {};
    fn = _options.fn || void 0;
    binding = binding_class["new"](context, model, field, options, fn);
    mocks = {
      binding: sinon.mock(binding),
      context: sinon.mock(context),
      model: sinon.mock(model),
      field: sinon.mock(field),
      options: sinon.mock(options),
      fn: sinon.mock(options),
      verify: function() {
        this.binding.verify();
        this.context.verify();
        this.model.verify();
        this.field.verify();
        this.options.verify();
        return this.fn.verify();
      }
    };
    return [mocks, binding];
  };

  NS.makeDoc = function(name, snapshot) {
    var Doc, doc;
    if (name == null) name = "document_name-" + (_.uniqueId());
    if (snapshot == null) snapshot = null;
    Doc = sharejs.Doc;
    doc = new Doc({}, name, {
      type: 'json'
    });
    doc.snapshot = snapshot;
    doc.submitOp = function(op, callback) {
      if (this.type.normalize != null) op = this.type.normalize(op);
      this.snapshot = this.type.apply(this.snapshot, op);
      if (callback) pendingCallbacks.push(callback);
      this.emit('change', op);
      setTimeout(this.flush, 0);
      return op;
    };
    return doc;
  };

}).call(this);
