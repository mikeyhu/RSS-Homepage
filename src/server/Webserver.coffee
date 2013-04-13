express = require 'express'
store = require './MongoStore.coffee'

exports.createWebServer = (port,connectionString)->
	
	app = express()
	app.use express.static(process.cwd() + '/src/resources/')
	app.use express.bodyParser()
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

	app.get '/latestByTag/json', (req,res)->
		ms = store.createMongostore(connectionString)
		ms.getLatestByTag req.query.tag,50, (err,result)->
			ms.close()
			if err then res.end(err)
			else
				res.json(result)

	app.get '/redirect', (req,res)->
		ms = store.createMongostore(connectionString)
		ms.updateEntryState req.query.id,"read",(err,result)->
			res.end(err) if err
			res.redirect(req.query.to) unless err

	app.get '/changeState', (req,res)->
		ms = store.createMongostore(connectionString)
		ms.updateEntryState req.query.id,req.query.state,(err,result)->
			res.end(err) if err
			res.end() unless err

	app.post '/changeMultipleStates', (req,res)->
		ms = store.createMongostore(connectionString)
		console.log "REQUEST:" + JSON.stringify(req.body)
		ms.updateEntryStates req.body,req.query.state,(err,result)->
			res.end(err) if err
			res.end() unless err

	# Start Server
	app.listen port, -> console.log "Server is listening on #{port}\nPress CTRL-C to stop server."