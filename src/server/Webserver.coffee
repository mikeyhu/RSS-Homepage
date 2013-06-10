express = require 'express'
store = require './MongoStore.coffee'
feedstore = require './FeedStore.coffee'
feed = require './Feed.coffee'
scheduler = require './Scheduler.coffee'

exports.createWebServer = (port,connectionString)->
	
	app = express()
	app.use express.static(process.cwd() + '/src/resources/')
	app.use express.bodyParser()
	app.set('views', __dirname + '/../resources/views')
	app.set('view engine', 'jade')

	app.get '/', (req, res)->
		res.render('index')

	app.get '/editFeeds', (req,res)->
		res.render('feeds')


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

	app.get '/latestByHostName/json', (req,res)->
		ms = store.createMongostore(connectionString)
		ms.getLatestByHostName req.query.hostName,50, (err,result)->
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

	app.get '/feeds/json', (req,res)->
		fs = feedstore.createFeedstore(connectionString)
		fs.getFeeds (err,result)->
			fs.close()
			if err then res.end(err)
			else
				res.json(result)

	app.get '/insertFeed', (req,res)->
		fs = feedstore.createFeedstore(connectionString)
		f = feed.createFeedDelimited(req.query.URL,req.query.tags)
		fs.insertFeed f,(err,result)->
			res.end(err) if err
			res.end() unless err
			sc = scheduler.createScheduler connectionString,15
			sc.scheduleFeed(f)

	app.get '/removeFeed', (req,res)->
		fs = feedstore.createFeedstore(connectionString)
		fs.deleteFeed feed.createFeedDelimited(req.query.URL,'').URL,(err,result)->
			res.end(err) if err
			res.end() unless err

	app.get '/tags/json', (req,res)->
		fs = feedstore.createFeedstore(connectionString)
		fs.getTags (err,result)->
			fs.close()
			if err then res.end(err)
			else
				res.json(result)

	app.get '/tagsAndHostNames/json', (req,res)->
		fs = feedstore.createFeedstore(connectionString)
		ms = store.createMongostore(connectionString)

		th = {}
		count = 0

		fin = (propertyName)->(err,result)->
			count++
			if err then res.end(err)
			else
				th[propertyName] = result
				if count == 2
					fs.close()
					ms.close()
					res.json(th)

		fs.getTags fin("tags")
		ms.getHostName fin("hostNames")

	# Start Server
	app.listen port, -> console.log "Server is listening on #{port}\nPress CTRL-C to stop server."