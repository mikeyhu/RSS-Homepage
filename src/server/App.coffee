webserver = require './WebServer.coffee'
scheduler = require './Scheduler.coffee'
collector = require './FeedCollector.coffee'
feed = require './Feed.coffee'
store = require './MongoStore.coffee'

connectionString = "mongodb://localhost:27017/feeds"

ms = store.createMongostore(connectionString)

s1 = scheduler.createScheduler collector.createFeedCollector(),ms,15
s1.scheduleFeed(feed.createFeed("http://feeds.bbci.co.uk/news/rss.xml",["News"]))

s2 = scheduler.createScheduler collector.createFeedCollector(),ms,15
s2.scheduleFeed(feed.createFeed("http://feeds.bbci.co.uk/sport/0/rss.xml?edition=uk",["Sport"]))

port = process.env.PORT or 5555
webserver.createWebServer(port,connectionString)