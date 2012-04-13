AS = require "alpha_simprini"
AS.Models.Grouping = AS.Model.extend ({delegate, include, def, defs}) ->
  @hasMany 'groups'

  def initialize: (@backingCollection, @groupByProperty) ->
    @_super()
    @groupMap = AS.Map.new()
    # TODO: send newvalue/oldvalue when triggering field changes ;)
    # that way an itemMap isn't neccessary.
    @itemMap = AS.Map.new()

    @backingCollection.bind
      event: "add"
      handler: @addToGroup
      context: this

    @backingCollection.bind 
      event: "remove"
      handler: @removeFromGroup
      context: this

    @backingCollection.bind 
      event: "change:#{@groupByProperty}"
      handler: @determineNewGroup
      context: this

    @backingCollection.each (item) => @addToGroup(item)

  def addToGroup: (item) ->
    name = item[@groupByProperty].get()
    unless group = @groupMap.get(name)
      group = AS.Models.Group.new(name: name)
      @groups.add(group)
      @groupMap.set(name, group)

    @itemMap.set item, group
    group.members.add(item)

  def removeFromGroup: (item) ->
    return unless group = @itemMap.get(item)
    group.members.remove(item)

  def determineNewGroup: (item) ->
    @removeFromGroup(item)
    @addToGroup(item)

# @currentUser.labors.groupBy "endDateGroup", (group) ->
#   @text group.name
#   @text "(" ;@group.binding "membersCount"; @text ")"
  
#   group.members.groupBy 'orgName', (group) ->
#     group.binding "name"
#     @text "("; @group.binding "membersCount"; @text ")"
