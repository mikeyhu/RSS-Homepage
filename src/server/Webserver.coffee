express = require 'express'
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

app = express()

app.use express.static(process.cwd() + '/src/resources/')
app.set('views', __dirname + '/../resources/views')
app.set('view engine', 'jade')

port = process.env.PORT or 5555

app.get '/', (req, res)->
	ms.getEntries {}, (err,result)->
		res.render('index',{entries:result})

# Start Server
app.listen port, -> console.log "Server is listening on #{port}\nPress CTRL-C to stop server."