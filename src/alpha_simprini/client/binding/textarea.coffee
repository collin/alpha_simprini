class AS.Binding.Textarea < AS.Binding.Input
  def makeContent: ->
    @context.$ @context.textarea(@options)
  # @::makeContent.doc =
  #   params: [
  #     []
  #   ]
  #   desc: """
  #
  #   """

