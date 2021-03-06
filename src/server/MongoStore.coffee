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

	prepareIndexes:(fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				@database.admin().command {'setParameter': '*', 'textSearchEnabled': true},(err,result)->
					if err then fun err,null
					else
						collection.ensureIndex {title: "text",summary: "text",feedName:"text"},fun

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
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.find(search).toArray @close(fun)

	getLatestRead:(amount,fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.find({$or: [{state:"read"}]}).sort({lastUpdatedState:-1}).limit(amount).toArray @close(fun)			


	getLatestNew:(amount,fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.find({$or: [{state:"new"},{state:"starred"}]}).sort({date:-1}).limit(amount).toArray @close(fun)			

	getLatestByTag:(tag,amount,fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.find({$and: [{tags:tag},{$or: [{state:"new"},{state:"starred"}]}]}).sort({date:-1}).limit(amount).toArray @close(fun)	

	getLatestByHostName:(hostName,amount,fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.find({$and: [{hostName:hostName},{$or: [{state:"new"},{state:"starred"}]}]}).sort({date:-1}).limit(amount).toArray @close(fun)	


	updateEntryStates:(listOfEntryIds,state,fun,current=0,listOfResults=[])->
		if listOfEntryIds.length <= current then fun(null,listOfResults)
		else
			@updateEntryState listOfEntryIds[current],state,(err,result)=>
				if err then fun(err,null)
				else
					listOfResults.push result
					@updateEntryStates listOfEntryIds,state,fun,current+1,listOfResults

	updateEntryState:(id,state,fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.update {id:id},{$set:{state:state,lastUpdatedState:Date.now()}},{w:1, upsert:true},@close(fun)

	getHostName:(fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.distinct 'hostName', @close(fun)

	getSearch:(searchTerm,amount,fun)->
		@connect (err,collection)=>
			if err then fun err,null
			else
				collection.db.command {text:entryCollection,search:searchTerm,limit:amount},(err,result)=>
					if err then fun err,null
					else
						r = (res.obj for res in result.results)
						@close(fun)(null,r)


#Aggregate state and tags...
#	db.entryData.aggregate({$group:{_id:{state:"$state",tags:"$tags"},count:{$sum:1}}})

