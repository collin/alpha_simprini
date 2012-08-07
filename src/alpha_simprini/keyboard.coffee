require "alpha_simprini"
AS.part("Keyboard").require """
  models/zone_controller models/zone_group models/zone

  views/keyboard_navigation views/selectable views/destructable views/zone
"""
AS.Keyboard.KEYS = jwerty.KEYS.keys