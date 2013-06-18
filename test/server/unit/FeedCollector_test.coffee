collector = require '../../../src/server/FeedCollector.coffee'
feed = require '../../../src/server/Feed.coffee'
expect = (require 'chai').expect

fakeRSS = "http://localhost:7777/rss.xml"

describe 'A Feed collector', ->

	it 'should be able to retrieve and parse some RSS XML', (done)->
		fc = collector.createFeedCollector(feed.createFeed(fakeRSS,["News"]))
		fc.requestFeed (err,result)->
			expect(err).to.be.null
			expect(result,"result").to.exist
			done()

	it 'should be able to retrieve a feed when provided with a Feed object', (done)->
		fc = collector.createFeedCollector(feed.createFeed(fakeRSS,["News"]))
		fc.collectFeed (err,result)->
			expect(err).to.be.null
			expect(result.title).to.equal "BBC News - Home"
			expect(result.entry[0].title).to.equal "Cameron halts press regulation talks"
			expect(result.entry[0].date).to.equal "2013-03-14T19:55:45.000Z"
			expect(result.entry[0].tags).to.eql ["News"]
			done()
