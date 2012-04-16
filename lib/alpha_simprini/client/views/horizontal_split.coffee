module "AS.Views", ->
  class @HorizontalSplit extends AS.View

    content: (args) ->
      @left ?= new AS.Views.Panel
      @bar ?= new AS.Views.Splitter
      @right ?= new AS.Views.Panel
      @el.append @left.el, @bar.el, @right.el
      