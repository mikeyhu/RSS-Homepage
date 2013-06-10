mongostore = require '../../../src/server/MongoStore.coffee'

expect = (require 'chai').expect
moment = require 'moment'
after = andAlso = require '../shared/Feed_steps.coffee'

connectionString = "mongodb://localhost:27000/feeds"

feedData = [
	{"title":"A news story","link":"http://a.news.story/","tags":["Technology"],"id":"1","hostName":"localhost"}
	{"title":"Another news story","link":"http://another.news.story/","tags":["News"],"id":"2","hostName":"otherhost"}
	]

similarData = [
	{"title":"A news story","link":"http://a.news.story/","tag"}
	{"title":"Third story","link":"http://third.news.story/"}
	]

entriesWithDates = [
	{title : "an entry",id : "anEntry",link : "http://an",date : moment().subtract('days',2).toJSON(), hostName:"a"}
	{title : "a newer entry",id : "aNewerEntry",link : "http://an",date : moment().subtract('days',1).toJSON(), hostName:"a"}
	{title : "a older entry",id : "aOlderEntry",link : "http://an",date : moment().subtract('days',3).toJSON(), hostName:"b"}
	]

twentyEntries = ({title:"title #{num}",id:"id#{num}"} for num in [0...20])

describe 'A mongodb store', ->
	beforeEach (done) ->
		@database = mongostore.createMongostore(connectionString)
		@database.clear (err,result)->
			done()

	it 'should be able to insert data into the datastore', (done)->
		@database.insertEntries [{"title":"An interesting tech story","link":"http://tech/story"}],(err,result)=>
			throw err if err
			@database.getEntries {"title":"An interesting tech story"},(err,result)->
				expect(result[0].title).to.equal "An interesting tech story"
				expect(result[0]._id).to.exist
				done()

	it 'should be able to only insert documents that do not already exist', (done)->
		@database.insertEntries feedData,(err,result)=>
			@database.count (err,result)=>
				throw err if err
				expect(result).to.equal 2
				@database.insertEntries similarData,(err,result)=>
					throw err if err
					@database.count (err,result)->
						throw err if err
						expect(result).to.equal 3
						done()

	it 'should be able to upsert an entry', (done)->
		@database.insertEntry {"title":"a new article", "link":"http://link/"},(err,result)=>
			throw err if err
			@database.count (err,result)->
				throw err if err
				expect(result).to.equal 1
				done()

	it 'should be able to upsert an entry and only add another if the title is different', (done)->
		after.inserting({"title":"a new article", "link":"http://link/"}).intoThe @database,(result)=>
			andAlso.inserting({"title":"a new article", "link":"http://link/"}).intoThe @database,(result)=>
				andAlso.countingEntriesInThe @database,(count)->
					expect(count).to.equal 1
					done()

	it 'should insert data and add a state=new to it', (done)->
		@database.insertEntry {"title":"An interesting tech story","link":"http://tech/story"},(err,result)=>
			throw err if err
			@database.getEntries {"title":"An interesting tech story"},(err,result)->
				expect(result[0].state).to.equal "new"
				done()

	it 'should be able to change state', (done)->
		@database.insertEntry {"title":"An interesting tech story","link":"http://tech/story","id":"123456789"},(err,result)=>
			throw err if err
			@database.updateEntryState "123456789","read",(err,result)=>
				@database.getEntries {"title":"An interesting tech story"},(err,result)->
					expect(result[0].title).to.equal "An interesting tech story"
					expect(result[0].state).to.equal "read"
					done()

	it 'should be able to change states of multiple items', (done)->
		after.insertingSome(entriesWithDates).intoThe @database,(result)=>
			@database.updateEntryStates ["anEntry","aNewerEntry"],"archived",(err,result)=>
				@database.getLatestNew 10, (err,result)->
					expect(result.length).to.equal 1
					expect(result[0].title).to.equal "a older entry"
					done()

	it 'should return items in order',(done)->
		after.insertingSome(entriesWithDates).intoThe @database,(result)=>
			@database.getLatestNew 10,(err,result)->
				expect(result[0].title).to.equal "a newer entry"
				expect(result[1].title).to.equal "an entry"
				expect(result[2].title).to.equal "a older entry"
				done()

	it 'should only return a limited number of entries',(done)->
		after.insertingSome(twentyEntries).intoThe @database,(result)=>
			@database.getLatestNew 10,(err,result)->
				expect(result.length).to.equal 10
				done()

	it 'should return both new and starred entries',(done)->
		after.insertingSome(entriesWithDates).intoThe @database,(result)=>
			@database.updateEntryState "aNewerEntry","starred",(err,result)=>
				@database.getLatestNew 10,(err,result)->
					expect(result.length).to.equal 3
					expect(result[0].title).to.equal "a newer entry"
					done()

	it 'should be able to limit results to certain tags',(done)->
		after.insertingSome(feedData).intoThe @database,(result)=>
			@database.getLatestByTag "News",10,(err,result)->
				expect(result.length).to.equal 1
				expect(result[0].title).to.equal "Another news story"
				done()

	it 'should return hostnames',(done)->
		after.insertingSome(entriesWithDates).intoThe @database,(result)=>
			@database.getHostName (err,result)->
				expect(result).to.eql(["a","b"])
				done()

	it 'should be able to limit results to certain hostNames',(done)->
		after.insertingSome(feedData).intoThe @database,(result)=>
			@database.getLatestByHostName "localhost",10,(err,result)->
				expect(result.length).to.equal 1
				expect(result[0].title).to.equal "A news story"
				done()