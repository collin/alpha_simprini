AS = require "alpha_simprini"
_ = require("underscore")
$ = require "jquery"
camelize = require("fleck").upperCamelize

AS.Models.File = AS.Model.extend ({delegate, include, def, defs}) ->
  defs familyClasses: AS.Map.new(-> this)
    
  defs registerFamilyClass: (mimeFamily, klass) ->
    @familyClasses.set(mimeFamily, klass)

  MIME_TYPES =
    "png": "image/png"
    "jpg": "image/jpeg"
    "jpeg": "image/jpeg"
    "gif": "image/gif"

  MIME = (path) ->
    file = $.url(path).attr("file")
    MIME_TYPES[file.split(".")[1]]

  MIME_FAMILY = /^(.*)\/(.*)$/

  defs classForMimeType: (mime) ->
    family = mime.match(MIME_FAMILY)[1]
    @familyClasses.get(family)

  @property "file"
  # @field "image"
  @field "name"
  @field "bytes"
  @field "mime"
  @field "url"

  defs build: (source) ->
    if _.isString(source)
      @build_from_url(source)
    else if source instanceof @::File
      @build_from_filereader(source)
    # else if source instanceof Image
    #   @build_from_image(source)

  # @build_from_url: (url) ->
  #   image = new Image
  #   image.src = url
  #   @build_from_image(image)

  defs build_from_filereader: (file) ->
    @classForMimeType(file.type).new(file:file)

  # @build_from_dom: (element) ->
  #   konstructor = class_for_mime()
  #   # pass

  # @::initialize.doc = 
  #   desc: """
  #     
  #   """
  def initialize: ->
    @_super.apply(this, arguments)
    if file = @file.get()
      @name.set file.name
      @bytes.set file.size
      @mime.set file.type
    # else if image = @image()
    #   image = $ image
    #   @mime MIME(image.attr "src")
    #   @name image.attr("title") or image.attr("alt") or $.url(image.attr("src")).attr("file") or "Untitled Image"
    #   @bytes 0

  # @::read.doc = 
  #   params: [
  #     ["callback", Function, true]
  #   ]
  #   desc: """
  #     
  #   """
  def read: (callback) ->
    # return callback(@dataURL) if @dataURL
    if @file.get()
      @readFile(callback)
    # else if @image()
    #   @readCanvas(callback)

  # @::readFile.doc = 
  #   params: [
  #     ["callback", Function, true]
  #   ]
  #   desc: """
  #     
  #   """
  def readFile: (callback) ->
    reader = new @FileReader
    reader.onload = (event) ->
      @dataURL = event.target.result
      callback(@dataURL)
    reader.readAsDataURL(@file.get())
    callback

  # def readCanvas: (callback) ->
  #   image = new Image
  #   image.onload = (event) =>
  #     canvas = document.createElement("canvas")
  #     canvas.width = image.width
  #     canvas.height = image.height
  #     canvas.getContext("2d").drawImage(image, 0, 0)
  #     @dataURL = canvas.toDataURL @mime()
  #     @bytes @dataURL.length
  #     callback(@dataURL)
  #   console.warn "FIXME: portable image proxy port"
  #   image.src = "http://catalogs.dev/?proxy_uri=#{@image().src}"

  # @::upload.doc = 
  #   desc: """
  #     
  #   """
  def upload: ->
    formdata = new FormData
    formdata.append "image[image]", @file.get()
    console.log formdata
    $.ajax
      url: "/images"
      type: "POST"
      data: formdata
      processData: false
      contentType: false
      error: => require("alpha_simprini").error("POST /images failed", this)
      success: (data, status, xhr) =>
        @url.set xhr.getResponseHeader("Location")
        @trigger("uploaded")

# Default File/FileReader implementaiton
# if unavailable you'll have to provide your own.
# server side implementations provided in test/models/file.coffee
AS.Models.File::FileReader = FileReader unless typeof FileReader is 'undefined'
AS.Models.File::File = File unless typeof File is 'undefined'