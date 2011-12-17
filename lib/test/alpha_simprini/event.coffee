for klass in [AS.Model, AS.Collection, AS.View]
  module "#{klass.name} Event Extensions"
  class of_prototype
  of_prototype.prototype = klass.prototype
  
  test "events bound are triggered by event with and without namespace", ->
    proof = false
    object = new of_prototype
    object.bind "event.namespace", -> proof = true
    object.trigger "event"
    ok proof, "triggers without namespace"
  
    proof = false
    object.trigger "event.namespace"
    ok proof, "triggers with namespace"

  test "events bound without namespace are not triggered by namespace", ->
    proof = false
    all_proof = false
    object = new of_prototype
    object.bind "all", -> all_proof = true
    object.bind "event", -> proof = true
    object.trigger "event.namespace"
    ok !proof, "doesn't trigger with namespace"
    ok all_proof, "triggers all event"

  test "unbind with namespace", ->
    proof = false
    other_proof = false
    none_proof = false
    object = new of_prototype
    object.bind "event.namespace", -> proof = true
    object.bind "event.other_namespace", -> other_proof = true
    object.bind "event", -> none_proof = true
  
    object.unbind "event.namespace"
  
    object.trigger "event"
  
    ok !proof, "clears binding for namespace"
    ok other_proof, "doesn't clear binding for other namespace"
    ok none_proof, "doesn't clear binding for no namespace"

