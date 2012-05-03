module "InstanceMethods"
test "discoversInstanceMethods", ->
  HasMethods = AS.Object.extend ({def}) ->
    def a: 1
    def b: 2

  deepEqual AS.instanceMethods(HasMethods), ["a", "b"]

test "traversesClasses", ->
  A = AS.Object.extend ({def}) ->
    def a: 1

  B = A.extend ({def}) ->
    def b: 2

  deepEqual AS.instanceMethods(B), ["b", "a"]
