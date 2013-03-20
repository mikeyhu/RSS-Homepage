mongostore = require '../../../src/server/MongoStore.coffee'
expect = (require 'chai').expect

connectionString = "mongodb://localhost:27000/feeds"

feedData = [
	{"title":"A news story","link":"http://a.news.story/"}
	{"title":"Another news story","link":"http://another.news.story/"}
	]

describe 'A mongodb store', ->
	beforeEach (done) ->
		@ms = mongostore.createMongostore(connectionString)
		@ms.clear (err,result)->
			done()

	it 'should be able to insert data into the datastore', (done)->
		@ms.insert {"title":"An interesting tech story","link":"http://tech/story"},(err,result)=>
			throw err if err
			expect(result[0].title).to.equal("An interesting tech story")
			expect(result[0]._id).to.exist
			done()

