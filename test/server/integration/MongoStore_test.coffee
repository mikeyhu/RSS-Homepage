mongostore = require '../../../src/server/MongoStore.coffee'
expect = (require 'chai').expect

connectionString = "mongodb://localhost:27000/feeds"

feedData = [
	{"title":"A news story","link":"http://a.news.story/","tag"}
	{"title":"Another news story","link":"http://another.news.story/"}
	]

similarData = [
	{"title":"A news story","link":"http://a.news.story/","tag"}
	{"title":"Third story","link":"http://third.news.story/"}
	]

describe 'A mongodb store', ->
	beforeEach (done) ->
		@ms = mongostore.createMongostore(connectionString)
		@ms.clear (err,result)->
			done()

	it 'should be able to insert data into the datastore', (done)->
		@ms.insertEntries [{"title":"An interesting tech story","link":"http://tech/story"}],(err,result)=>
			throw err if err
			@ms.getEntries {"title":"An interesting tech story"},(err,result)->
				expect(result[0].title).to.equal "An interesting tech story"
				expect(result[0]._id).to.exist
				done()

	it 'should be able to only insert documents that do not already exist', (done)->
		@ms.insertEntries feedData,(err,result)=>
			throw err if err
			@ms.count (err,result)=>
				throw err if err
				expect(result).to.equal 2
				@ms.insertEntries similarData,(err,result)=>
					throw err if err
					@ms.count (err,result)->
						throw err if err
						expect(result).to.equal 3
						done()

	it 'should be able to upsert an entry', (done)->
		@ms.insertEntry {"title":"a new article", "link":"http://link/"},(err,result)=>
			throw err if err
			@ms.count (err,result)->
				throw err if err
				expect(result).to.equal 1
				done()

	it 'should be able to upsert an entry and only add another if the title is different', (done)->
		@ms.insertEntry {"title":"a new article", "link":"http://link/"},(err,result)=>
			throw err if err
			@ms.insertEntry {"title":"a new article", "link":"http://link/"},(err,result)=>
				throw err if err
				@ms.count (err,result)->
					throw err if err
					expect(result).to.equal 1
					done()

	it 'should insert data and add a state=new to it', (done)->
		@ms.insertEntry {"title":"An interesting tech story","link":"http://tech/story"},(err,result)=>
			throw err if err
			@ms.getEntries {"title":"An interesting tech story"},(err,result)->
				expect(result[0].state).to.equal "new"
				done()

	it 'should be able to change state', (done)->
		@ms.insertEntry {"title":"An interesting tech story","link":"http://tech/story","id":"123456789"},(err,result)=>
			throw err if err
			@ms.updateEntryState "123456789","read",(err,result)=>
				@ms.getEntries {"title":"An interesting tech story"},(err,result)->
					expect(result[0].title).to.equal "An interesting tech story"
					expect(result[0].state).to.equal "read"
					done()
