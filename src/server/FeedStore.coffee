mongo = require 'mongodb'

collectionName = "feedData"

exports.createFeedstore = (connectionString)->

	database = null

	connect:(fun)->
		mongoClient = mongo.MongoClient
		mongoClient.connect connectionString,(err,db)=>
			@database = db
			fun err,null if err
			fun null,db.collection(collectionName) unless err

	clear:(fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.remove {},fun

	close:(fun)->(err,result)=>
		if @database
			@database.close()
		fun(err,result)

	insertFeed:(feed,fun)->
		console.log feed
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.update {URL:feed.URL}, {$set:feed}, {w:1,upsert:true}, @close(fun)

	insertFeeds:(listOfFeeds,fun,current=0,listOfResults=[])->
		if listOfFeeds.length <= current then fun(null,listOfResults)
		else
			@insertFeed listOfFeeds[current],(err,result)=>
				if err then fun(err,null)
				else
					listOfResults.push result
					@insertFeeds listOfFeeds,fun,current+1,listOfResults

	getFeeds:(fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.find().toArray @close(fun)

	getTags:(fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.distinct 'tags', @close(fun)

	deleteFeed:(URL,fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.remove {URL:URL}, @close(fun)