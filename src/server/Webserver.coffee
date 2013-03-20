express = require 'express'

app = express()

app.use express.static(process.cwd() + '/src/resources/')
app.set('views', __dirname + '/../resources/views')
app.set('view engine', 'jade')

port = process.env.PORT or 5555

app.get '/', (req, res)->
	res.render('index',{})

# Start Server
app.listen port, -> console.log "Server is listening on #{port}\nPress CTRL-C to stop server."