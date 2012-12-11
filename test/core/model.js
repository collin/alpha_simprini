(function() {

  module("Model");

  test("has a place for all models", function() {
    return deepEqual(AS.All, {
      byCid: {},
      byId: {},
      byIdRef: {}
    });
  });

  test("puts new models in that place", function() {
    var model;
    model = AS.Model["new"]();
    equal(AS.All.byCid[model.cid], model, "puts model in AS.All.byCid");
    equal(AS.All.byId[model.id], model, "puts model in AS.All.byId");
    return equal(AS.All.byIdRef[model.idRef], model, "puts model in AS.All.byIdRef");
  });

}).call(this);
