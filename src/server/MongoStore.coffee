mongo = require 'mongodb'

entryCollection = "entryData"

exports.createMongostore = (connectionString)->

	connect:(fun)->
		mongoClient = mongo.MongoClient
		mongoClient.connect connectionString,(err,db)->
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

	insertEntries:(listOfEntries,fun,current=0,listOfResults=[])->
		if listOfEntries.length <= current then fun(null,listOfResults)
		else
			@insertEntry listOfEntries[current],(err,result)=>
				if err then fun(err,null)
				else
					listOfResults.push result
					@insertEntries listOfEntries,fun,current+1,listOfResults

	insertEntry:(entry,fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.update {title:entry.title}, {$setOnInsert:{state:"new"},$set:entry},{w:1, upsert:true},fun

	getEntries:(search,fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.find(search).toArray fun

	updateEntryState:(id,state,fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.update {id:id},{$set:{state:state}},{w:1, upsert:true},fun

