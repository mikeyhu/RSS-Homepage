express = require 'express'
store = require './MongoStore.coffee'

exports.createWebServer = (port,connectionString)->
	
	app = express()
	app.use express.static(process.cwd() + '/src/resources/')
	app.set('views', __dirname + '/../resources/views')
	app.set('view engine', 'jade')

	app.get '/', (req, res)->
		res.render('index')

	app.get '/latest/json', (req,res)->
		ms = store.createMongostore(connectionString)
		ms.getLatestNew 50, (err,result)->
			ms.close()
			if err then res.end(err)
			else
				res.json(result)

	app.get '/redirect', (req,res)->
		ms = store.createMongostore(connectionString)
		ms.updateEntryState req.query.id,"read",(err,result)->
			res.end(err) if err
			res.redirect(req.query.to) unless err


	# Start Server
	app.listen port, -> console.log "Server is listening on #{port}\nPress CTRL-C to stop server."