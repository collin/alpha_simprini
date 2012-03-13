AS = require "alpha_simprini"
Client = AS.part("Client")
_ = require "underscore"

Client.require """
  dom view view_model binding_group binding view_events

  views/panel views/region

  models/targets

  application
"""
