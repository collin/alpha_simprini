module "InstanceMethods"
test "discoversInstanceMethods", ->
  HasMethods = AS.Object.extend ({def}) ->
    def a: 1
    def b: 2

  ok "a" in AS.instanceMethods(HasMethods)
  ok "b" in AS.instanceMethods(HasMethods)

test "traversesClasses", ->
  A = AS.Object.extend ({def}) ->
    def a: 1

  B = A.extend ({def}) ->
    def b: 2

  ok "a" in AS.instanceMethods(B)
  ok "b" in AS.instanceMethods(B)
