AS = require("alpha_simprini").AS

AS.require = require

if process
	AS.require_tree = (path) ->	
	  require("glob").glob "#{path}/**/*.coffee", (error, paths) ->
			require(path) for path in paths
  
	AS.require_dir = (path) ->
	  require("glob").glob "#{path}/*.coffee", (error, paths) ->
			require(path) for path in paths
			
else if window
	AS.require_tree = ->
	AS.require_dir = ->
		
  