(function() {

  NS.AView = AS.View.extend();

  NS.Viewed = AS.Model.extend(function(_arg) {
    var def;
    def = _arg.def;
    this.field("field");
    this.hasMany("many");
    this.hasOne("one");
    return def({
      other: function() {}
    });
  });

  module("ViewModel");

  test("builds viewmodels", function() {
    var model, view, vm;
    view = NS.AView["new"]();
    model = NS.Viewed["new"]();
    vm = AS.ViewModel.build(view, model);
    equal(vm.view, view);
    return equal(vm.model, model);
  });

  test("caches constructors", function() {
    var vm1, vm2;
    vm1 = AS.ViewModel.build(NS.AView["new"](), NS.Viewed["new"]());
    vm2 = AS.ViewModel.build(NS.AView["new"](), NS.Viewed["new"]());
    return equal(vm1.constructor, vm2.constructor);
  });

  test("configures constructor", function() {
    var bindables, vm;
    vm = AS.ViewModel.build(NS.AView["new"](), NS.Viewed["new"]());
    bindables = vm.constructor.bindables;
    equal(bindables.field, AS.Binding.Field);
    equal(bindables.many, AS.Binding.Many);
    return equal(bindables.one, AS.Binding.One);
  });

}).call(this);
