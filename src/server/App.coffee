webserver = require './Webserver.coffee'
scheduler = require './Scheduler.coffee'
feed = require './Feed.coffee'
feedstore = require './FeedStore.coffee'

connectionString = "mongodb://localhost:27017/feeds"

schedule = (feed)->
	sc = scheduler.createScheduler connectionString,15
	sc.scheduleFeed(feed)

fs = feedstore.createFeedstore(connectionString)
fs.getFeeds (err,feeds)->
	schedule f for f in feeds

port = process.env.PORT or 5555
webserver.createWebServer(port,connectionString)