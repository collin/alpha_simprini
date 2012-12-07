class AS.Models.Group < AS.Model
  @property "metaData"
  @field "name"
  @hasMany "members"

  @virtualProperties 'members', membersCount: -> @members.backingCollection.length
