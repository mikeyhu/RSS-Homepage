cluster = require 'cluster'
webserver = require './Webserver.coffee'
scheduler = require './Scheduler.coffee'
feed = require './Feed.coffee'
feedstore = require './FeedStore.coffee'

process.execPath = 'coffee'

connectionString = "mongodb://localhost:27017/feeds"

if cluster.isMaster
	#only need 1 worker
	cluster.fork()

	cluster.on 'exit',(deadWorker, code, signal)->
		#Restart the worker
		console.log "Worker [#{deadWorker.process.pid}] exited with code [#{code}], signal [#{signal}]"
		cluster.fork()
else
	schedule = (feed)->
		if feed.URL.lastIndexOf("https", 0) == -1
			sc = scheduler.createScheduler connectionString,15
			sc.scheduleFeed(feed)

	fs = feedstore.createFeedstore(connectionString)
	fs.getFeeds (err,feeds)->
		schedule f for f in feeds

	port = process.env.PORT or 5555
	webserver.createWebServer(port,connectionString)