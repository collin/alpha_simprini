module "AS.View"
test "::klass_string()", ->
  equal new AS.View().klass_string(), "ASView", "basic klass_string is ASView"
  
  class SomeView extends AS.View
  
  equal new SomeView().klass_string(), "ASView.SomeView", "subclasses include parent class string"
    
test "::element_string()", ->
  equal new AS.View().element_string(), "div.ASView", "defaults to a div + klass_string"
  equal new AS.View(tagName:"tagname").element_string(), "tagname.ASView", "allows setting of a tag"
  
  model = {cid: "cid"}
  
  equal new AS.View(model:model).element_string(), "div.ASView#cid.Object", "uses the cid/class of an associated model as the dom id/class"

test "::build_element()", ->
  ok new AS.View().build_element().is(new AS.View().element_string()), "uses jQuery.satisfy to build the element"
  model = {cid: "cid"}
  ok new AS.View(model:model).build_element().is(new AS.View(model:model).element_string()), "with more complex element"

test "element is jquery wrapped", ->
  equal new AS.View().el.constructor, jQuery

test "configuration", ->
  view = new AS.View option:"OPTION"
  equal view.option, "OPTION", "allow setting of arbitrary options from constructor"

test "event delegation", ->
  click_proof = false
  member_proof = false
  button_proof = false
  guard_pass_proof = false
  guard_fail_proof = false
  
  class BoundView extends AS.View
    constructor: -> 
      @member = new AS.Model
      super
      @el.append @button = jQuery.satisfy("button")
      @render()
    
    events:
      "click": "click_handler"
      "click button": "button_handler"
      "event @member": "member_handler"
      "pass{pass:true} @member": "guard_pass_handler"
      "fail{pass:false} @member": "guard_fail_handler"
    
    click_handler: -> click_proof = true
    member_handler: -> member_proof = true
    button_handler: -> button_proof = true
    guard_fail_handler: -> guard_fail_proof = true
    guard_pass_handler: -> guard_pass_proof = true
    
    render: -> @el.appendTo(document.body)
    
  view = new BoundView
  
  view.el.click()
  view.member.trigger("event")
  view.button.click()
  view.member.trigger("pass", pass: true)
  view.member.trigger("fail", pass: true)
  
  ok click_proof, "binds simple dom events to view element"
  ok member_proof, "binds to events of member objects"
  ok button_proof, "binds to events of elements inside view"
  ok guard_pass_proof, "correct values get past the guard"
  ok !guard_fail_proof, "incorrect values blocked by the guard"
  
  view.el.remove()