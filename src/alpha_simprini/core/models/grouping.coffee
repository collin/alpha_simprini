class AS.Models.Grouping < AS.Model
  @hasMany 'groups'

  def initialize: (@backingCollection, @groupByProperty, @metaData={}) ->
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
  # @::initialize.doc =
  #   params: [
  #     ["@backingCollection", AS.Collection, true]
  #     ["@groupByProperty", String, true]
  #     ["@metaData", Object, false, default: {}]
  #   ]
  #   desc: """
  #
  #   """

  def addToGroup: (item) ->
    name = item[@groupByProperty].get() ? "default"
    unless group = @groupMap.get(name)
      group = AS.Models.Group.new(name: name, metaData: @metaData)
      @groups.add(group)
      @groupMap.set(name, group)

    @itemMap.set item, group
    group.members.add(item)
  # @::addToGroup.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  def removeFromGroup: (item) ->
    return unless group = @itemMap.get(item)
    group.members.remove(item)
  # @::removeFromGroup.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

  def determineNewGroup: (item) ->
    @removeFromGroup(item)
    @addToGroup(item)
  # @::determineNewGroup.doc =
  #   params: [
  #     ["item", AS.Model, true]
  #   ]
  #   desc: """
  #
  #   """

# @currentUser.labors.groupBy "endDateGroup", (group) ->
#   @text group.name
#   @text "(" ;@group.binding "membersCount"; @text ")"

#   group.members.groupBy 'orgName', (group) ->
#     group.binding "name"
#     @text "("; @group.binding "membersCount"; @text ")"
