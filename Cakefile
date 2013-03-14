{exec} = require "child_process"

REPORTER = "spec"

task "dev", "run the server", ->
  exec "coffee src/server/webserver.coffee"
  console.log "running server, use CTRL-c to quit"

task "test", "run all tests", ->
  invoke "unit"

task "unit", "run unit tests", ->
  exec "NODE_ENV=test 
    mocha 
    --compilers coffee:coffee-script
    --reporter #{REPORTER}
    --require coffee-script 
    --colors
    --recursive
  ", (err, output) ->
    throw err if err
    console.log output

