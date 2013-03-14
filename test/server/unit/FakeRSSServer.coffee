express = require 'express'

app = express()
app.use express.static(process.cwd() + '/test/resources')
port = 7777

# Start Server
app.listen port, -> console.log "FakeRSS server is listening on #{port}\nPress CTRL-C to stop server."