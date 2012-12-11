(function() {
  var mockBinding;

  mockBinding = NS.mockBinding;

  module("Binding");

  test("stashes the binding container", function() {
    var binding, mocks, _ref;
    _ref = mockBinding(AS.Binding), mocks = _ref[0], binding = _ref[1];
    return equal(binding.container[0], binding.context.currentNode);
  });

  test("stashes the binding group", function() {
    var binding, mocks, _ref;
    _ref = mockBinding(AS.Binding), mocks = _ref[0], binding = _ref[1];
    return equal(binding.bindingGroup, binding.context.bindingGroup);
  });

  test("gets the field value", function() {
    var binding, mocks, _ref;
    _ref = mockBinding(AS.Binding), mocks = _ref[0], binding = _ref[1];
    return equal(binding.fieldValue(), "value");
  });

}).call(this);
