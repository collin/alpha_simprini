{rpad} = AS.util

class AS.Models.Color < AS.Model
  @field 'red', type: AS.Model.Number
  @field 'green', type: AS.Model.Number
  @field 'blue', type: AS.Model.Number
  @field 'alpha', default: 0, type: AS.Model.Number

  @virtualProperties "red", "green", "blue", "alpha",
    ahex: -> [
      "#"
      rpad((@red.get() or 0).toString(16), 2, "0")
      rpad((@green.get() or 0).toString(16), 2, "0")
      rpad((@blue.get() or 0).toString(16), 2, "0")
      rpad((@alpha.get() or 0).toString(16), 2, "0")
    ].join("")

    rgba: -> [
      "rgba("
      [@red.get() or 0, @green.get() or 0, @blue.get() or 0, (@alpha.get()/255).toFixed(2)].join()
      ")"
    ].join("")
