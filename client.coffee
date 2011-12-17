AS = require "alpha_simprini"
Client = AS.part("Client")
_ = require "underscore"

Client.require """
  dom view view_events view_model binding binding_group
  
  application
"""
