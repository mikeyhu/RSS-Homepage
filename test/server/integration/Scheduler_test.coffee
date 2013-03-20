mongostore = require '../../../src/server/MongoStore.coffee'
collector = require '../../../src/server/FeedCollector.coffee'
feed= require '../../../src/server/Feed.coffee'
scheduler= require '../../../src/server/Scheduler.coffee'

expect = (require 'chai').expect

connectionString = "mongodb://localhost:27000/feeds"
fakeRSS = "http://localhost:7777/rss.xml"

describe 'A scheduler', ->
	beforeEach (done) ->
		@ms = mongostore.createMongostore(connectionString)
		@collector = collector.createFeedCollector()
		@scheduler = scheduler.createScheduler @collector,@ms
		@ms.clear (err,result)->
			done()

	it 'should be able to insert feed data into a store', (done)->
		newsFeed = feed.createFeed fakeRSS, ["News"]
		@scheduler.runFeed newsFeed, (err,result)=>
			throw err if err
			@ms.count (err,result)->
				throw err if err
				expect(result).to.equal 2
				done()

	it 'should be able to insert feed data into a store and find it again', (done)->
		newsFeed = feed.createFeed fakeRSS, ["News"]
		@scheduler.runFeed newsFeed, (err,result)=>
			throw err if err
			@ms.getEntries {"tags":"News"},(err,result)->
				throw err if err
				expect(result.length).to.equal 2
				expect(result[0].title).to.equal "Cameron halts press regulation talks"
				expect(result[0].tags).to.eql ["News"]
				done()

	it 'should be able to schedule a feed and retrieve a scheduleid', ->
		newsFeed = feed.createFeed fakeRSS, ["News"]
		scheduleId = @scheduler.scheduleFeed newsFeed
		expect(scheduleId).to.exist