exports.createScheduler = (collector,store,waitTime) ->

	waitTime: waitTime ? 1000*60*15 #15 minutes

	scheduleFeed:(feed)->
		@runFeed feed
		setInterval @runFeed, waitTime,feed

	runFeed:(feed,fun)->
		collector.collectFeed feed,(err,result)->
			if err 
				console.log err
				fun err,null
			else
				store.insertEntries result.entry,(err,result)->
					if err then console.log err
					fun(err,result)





