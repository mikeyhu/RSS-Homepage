exports.createScheduler = (collector,store,waitTime = 15) ->

	scheduleFeed:(feed)->
		finishFeed = (err,result)->
			console.log("Finished scheduled run for '#{feed.URL}' at #{new Date().toJSON()}")
		@runFeed feed,finishFeed
		setInterval @runFeed, waitTime*1000*60,feed,finishFeed

	runFeed:(feed,fun)->
		collector.collectFeed feed,(err,result)->
			if err 
				console.log err
				fun err,null
			else
				store.insertEntries result.entry,(err,result)->
					if err then console.log err
					fun(err,result)





