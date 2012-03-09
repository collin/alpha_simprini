# AS = require("alpha_simprini")
# AS.Callbacks = new AS.Mixin
#   depends_on: [AS.InheritableAttrs]
#   class_methods:
#     define_callbacks: (all) ->
#       for key, callbacks of all
#         do (key, callbacks) =>
#           for callback in callbacks or []
#             do (callback) =>
#               @["#{key}_#{callback}"] = (fn) ->
#                 @push_inheritable_item("#{key}_#{callback}_callbacks", fn)
            
#   instance_methods:
#     run_callbacks: (name) ->
#       for callback in @constructor["#{name}_callbacks"] || []
#         callback.call(null, this)