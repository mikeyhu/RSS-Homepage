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
				expect(result[0].title).to.equal("An interesting tech story")
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

###	it 'should be able to delete data from the datastore and count results', (done)->
		@ms.count (err,result)=>
			result.should.equal 0
			@ms.insert {name:"mike"},(err,result)=>
				@ms.count (err,result)=>
					result.should.equal 1
					@ms.clear (err,result)=>
						@ms.count (err,result)->
							result.should.equal 0
							done()

	it 'should be able to get facet information about data in the db', (done)->
		@ms.insert setData,(err,result)=>
			@ms.getFacet null,"theme",(err,result)->
				result.should.eql [{_id:"Star Wars",count:2},{_id:"Space",count:1}]
				for facet in result when facet._id=="Star Wars" 
					facet.count.should.equal 2
				done()
	
	it 'should be able to get facet information with an existing facet search', (done)->
		@ms.insert setData,(err,result)=>
			facets={"year":"1996"}
			@ms.getFacet facets,"theme",(err,result)->
				result.length.should.equal 1
				done()

	it 'should be able to get Set information', (done)->			
		@ms.insert setData,(err,result)=>
			@ms.getSets null,(err,result)->
				result.length.should.equal 3
				result[0].theme.should.equal "Star Wars"
				done()

	it 'should be able to get Set information with an existing facet search', (done)->
		@ms.insert setData,(err,result)=>
			facets={"theme":"Star Wars"}
			@ms.getSets facets,(err,result)->
				result.length.should.equal 2
				done()###
