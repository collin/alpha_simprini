text "<!DOCTYPE html>"
html ->
  head ->
    title "AlphaSimprini Todo"
    script src: "/node_modules.js"
    script  """
            require("alpha_simprini").params = {list_id: "#{@id}"};
            """
    
    coffeescript ->
      _ = require("underscore")
      io = require("socket.io-client")
      io.transports = _(io.transports).chain().without("websocket").uniq().value()
      
      Todo = require "todo"
      require("jquery") ->
        Todo.app = new Todo.Application
      
  body ->
