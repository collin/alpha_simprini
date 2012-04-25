AS = require "alpha_simprini"
Client = AS.part("Client")
_ = require "underscore"

Client.require """
  dom view view_model binding_group view_events

  binding
  binding/container

    binding/model binding/field binding/input binding/select binding/file
    binding/check_box binding/edit_line binding/one binding/many

  views/panel views/region views/dialog

  models/targets

  application
"""
