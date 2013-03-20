xml2js = require 'xml2js'
http = require 'http'
_ = require 'underscore'

exports.createFeedCollector = ->

	requestFeed:(URL,fun)->
		data=""
		http.get URL, (res) ->
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
		parser.parseString data, (err,result)=>
			if err
				fun(err,null)
			else if result.rss
				fun(null,@parseRSS result.rss.channel)
			else if result.feed
				fun(null,@parseAtom result.feed)
			else
				fun("Unable to parse feed",null)

	parseAtom:(data)->
		title: data.title
		entry: @parseEntry(e) for e in _.flatten([data.entry])

	parseEntry:(e)->
		title: e.title
		link: e.link.$.href

	parseRSS:(data)->
		title: data.title
		entry: _.flatten([data.item])

