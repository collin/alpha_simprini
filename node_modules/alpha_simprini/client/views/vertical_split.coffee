module "AS.Views", ->
  class @VerticalSplit extends AS.View

    initialize: () ->
      @top ?= new AS.Views.Panel
      @bar ?= new AS.Views.Splitter
      @bottom ?= new AS.Views.Panel
      @el.append @top.el, @bar.el, @bottom.el
