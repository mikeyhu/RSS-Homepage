express = require 'express'
store = require './MongoStore.coffee'

exports.createWebServer = (port,connectionString)->
	ms = store.createMongostore(connectionString)

	app = express()
	app.use express.static(process.cwd() + '/src/resources/')
	app.set('views', __dirname + '/../resources/views')
	app.set('view engine', 'jade')

	app.get '/', (req, res)->
		ms.getEntries {}, (err,result)->
			res.render('index',{entries:result})

	app.get '/latest/json', (req,res)->
		ms.getLatestNew 20, (err,result)->
			res.json(result)

	# Start Server
	app.listen port, -> console.log "Server is listening on #{port}\nPress CTRL-C to stop server."