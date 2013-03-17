xml2js = require 'xml2js'
http = require 'http'

exports.createRSSCollector = ->

	requestFeed:(connectionString,fun)->
		data=""
		http.get connectionString, (res) ->
			res.setEncoding('utf8')
			res.on 'data', (chunk)->
				data=data+chunk
			res.on 'end', ()->
				fun(null,data)
		.on 'error', (e)->	
			console.log("Got error: " + e.message)
			fun(e.message,null)

	parseFeed:(data,fun) ->
		parser = new xml2js.Parser({explicitArray:false})
		parser.parseString data, (err,result)->
			if result.rss
				fun(err,result.rss.channel)
			else if result.feed
				fun(err,result.feed)
			else
				fun("Unable to parse feed",null)


