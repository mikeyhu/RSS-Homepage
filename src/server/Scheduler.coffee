store = require './MongoStore.coffee'

exports.createScheduler = (collector,connectionString,waitTime = 15) ->

	scheduleFeed:(feed)->
		finishFeed = (err,result)->
			logError err,feed if err
			console.log("Finished scheduled run for '#{feed.URL}' at #{new Date().toJSON()}")
		@runFeed feed,finishFeed
		setInterval @runFeed, waitTime*1000*60,feed,finishFeed

	runFeed:(feed,fun)->
		ms = store.createMongostore(connectionString)
		collector.collectFeed feed,(err,result)->
			if err 
				logError err,feed
				fun err,null
			else
				ms.insertEntries result.entry,(err,result)->
					if err then logError err,feed
					fun(err,result)

logError = (err,feed)->
	console.log "Error occured: #{err} for feed: #{feed.URL}"



