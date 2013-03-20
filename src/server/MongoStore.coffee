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

	insert:(data,fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.insert data,{w:1},fun

	getEntries:(search,fun)->
		@connect (err,collection)->
			if err then fun err,null
			else
				collection.find(search).toArray fun

