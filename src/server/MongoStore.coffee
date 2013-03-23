mongo = require 'mongodb'

entryCollection = "entryData"

exports.createMongostore = (connectionString)->

	database = null

	connect:(fun)->
		mongoClient = mongo.MongoClient
		mongoClient.connect connectionString,(err,db)=>
			@database = db
			fun err,null if err
			fun null,db.collection(entryCollection) unless err

	clear:(fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.remove {},fun

	count:(fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.count fun

	close:(fun)->(err,result)=>
		if @database
			@database.close()
		fun(err,result)

	insertEntries:(listOfEntries,fun,current=0,listOfResults=[])->
		if listOfEntries.length <= current then fun(null,listOfResults)
		else
			@insertEntry listOfEntries[current],(err,result)=>
				if err then fun(err,null)
				else
					listOfResults.push result
					@insertEntries listOfEntries,fun,current+1,listOfResults

	insertEntry:(entry,fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.update {id:entry.id}, {$setOnInsert:{state:"new"},$set:entry}, {w:1,upsert:true}, @close(fun)

	getEntries:(search,fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.find(search).toArray fun

	getLatestNew:(amount,fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.find({$or: [{state:"new"},{state:"starred"}]}).sort({date:-1}).limit(amount).toArray fun			

	updateEntryState:(id,state,fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.update {id:id},{$set:{state:state}},{w:1, upsert:true},fun

