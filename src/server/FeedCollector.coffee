http = require 'http'
parser = require './FeedParser.coffee'
url = require 'url'

exports.createFeedCollector = (feed)->

	parsedURL:if feed then url.parse(feed.URL,true) else {}

	collectFeed:(fun)->
		fp = parser.createFeedParser(feed)
		console.log "Collecting from '#{feed.URL}' at #{new Date().toJSON()}"
		@requestFeed (err,data)=>
			if err then fun(err,null)
			else
				fp.parseFeed data, fun

	requestFeed:(fun)->
		data = ""
		req = http.request @parsedURL, (res) ->
			res.setEncoding('utf8')
			res.on 'data', (chunk)->
				data = data + chunk
			res.on 'end', ()->
				fun(null,data)
		.on 'error', (e)->	
			console.log("Got error: " + e.message)
			fun(e.message,null)
		req.end()

