AS = require "alpha_simprini"

AS.Models.Group = AS.Model.extend ({delegate, include, def, defs}) ->
  @field "name"
  @hasMany "members"

  @virtualProperties 'members', membersCount: -> @members.backingCollection.length
