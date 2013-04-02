mongostore = require '../../../src/server/FeedStore.coffee'

expect = (require 'chai').expect
moment = require 'moment'

connectionString = "mongodb://localhost:27000/feeds"

feedData = [
	{URL:"http://feed/a",tags:["Technology"]}
	{URL:"http://feed/b",tags:["News"]}
	]

describe 'A mongodb store for Feed information', ->
	beforeEach (done) ->
		@database = mongostore.createFeedstore(connectionString)
		@database.clear (err,result)->
			done()

	it 'should be able to insert data into the datastore', (done)->
		@database.insertFeed {URL:"http://feed/c",tags:["Sport"]},(err,result)=>
			throw err if err
			@database.getFeeds (err,result)->
				expect(result[0].URL).to.equal "http://feed/c"
				done()

	it 'should be able to find all the tags in the store', (done)->
		@database.insertFeeds feedData,(err,result)=>
			throw err if err
			@database.getTags (err,result)->
				expect(result).to.eql ["Technology","News"]
				done()

	it 'should be able to delete a feed', (done)->
		@database.insertFeeds feedData,(err,result)=>
			throw err if err
			@database.deleteFeed "http://feed/a",(err,result)=>
				throw err if err
				@database.getFeeds (err,result)->
					expect(result.length).to.equal 1
					expect(result[0].URL).to.equal "http://feed/b"
					done()
