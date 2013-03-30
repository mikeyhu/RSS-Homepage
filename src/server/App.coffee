webserver = require './Webserver.coffee'
scheduler = require './Scheduler.coffee'
feed = require './Feed.coffee'
store = require './MongoStore.coffee'

connectionString = "mongodb://localhost:27017/feeds"



schedule = (feed)->
	sc = scheduler.createScheduler connectionString,15
	sc.scheduleFeed(feed)


feeds = [
	feed.createFeed("http://feeds.bbci.co.uk/news/rss.xml",["News"]),
	feed.createFeed("http://feeds.macrumors.com/MacRumors-All?format=xml",["Technology"]),
	feed.createFeed("http://www.theverge.com/rss/index.xml",["Technology"])
]

schedule f for f in feeds

port = process.env.PORT or 5555
webserver.createWebServer(port,connectionString)