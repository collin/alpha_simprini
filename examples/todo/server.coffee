AS = require "alpha_simprini"
ModuleLoader = require "module_loader"
share = require("share").server
express = require "express"
connect = require "connect"
pathname = require "path"

app = express.createServer(connect.logger())

app.set 'view engine', 'coffee'
app.register '.coffee', require('coffeekup').adapters.express

share.attach app, db: type: "none"

new ModuleLoader
  server: app
  env: "production"
  module_root: pathname.resolve("./node_modules")
  ignorefile: pathname.resolve("./.stitchignore")
  packages: "jquery underscore underscore.string jwerty socket.io-client share rangy-core pathology taxialpha_simprini fleck todo".split(" ")


app.get "/list/:id", (req, res) ->
  res.render "list", id: req.params.id, layout: false

app.listen 3210 || process.env.PORT
console.log """
  AlphaSimprini Todo example running... 
  http://#{app.address().address}:#{app.address().port}/list/one
"""
