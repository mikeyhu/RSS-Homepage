xml2js = require 'xml2js'
http = require 'http'
url = require 'url'
_ = require 'underscore'
moment = require 'moment'

exports.createFeedCollector = (feed)->

	collectFeed:(fun)->
		console.log "Collecting from '#{feed.URL}' at #{new Date().toJSON()}"
		@requestFeed feed.URL,(err,data)=>
			if err then fun(err,null)
			else
				@parseFeed data, fun

	requestFeed:(URL,fun)->
		options = url.parse(URL,true)
		data=""
		req = http.request options, (res) ->
			res.setEncoding('utf8')
			res.on 'data', (chunk)->
				data=data+chunk
			res.on 'end', ()->
				fun(null,data)
		.on 'error', (e)->	
			console.log("Got error: " + e.message)
			fun(e.message,null)
		req.end()

	parseFeed:(data,fun) ->
		parser = new xml2js.Parser({explicitArray:false})
		parser.parseString data, (err,result)=>
			if err
				fun(err,null)
			else if result?.rss
				fun(null,@parseRSS result.rss.channel)
			else if result?.feed
				fun(null,@parseAtom result.feed)
			else
				fun("Unable to parse feed",null)

	parseAtom:(data)->
		title: data.title
		entry: @parseEntry(e,data.title) for e in _.flatten([data.entry])

	parseEntry:(e,feedName)->
		title: e.title
		link: if e.link.$ then e.link.$.href else e.link
		id: if e.guid then e.guid._ else e.id
		date: moment(e.pubDate ? e.updated).toJSON()
		summary: e.summary ? e.description ? ''
		#image: e['media:thumbnail'] ? ''
		tags: feed?.tags
		feedName: feedName ? ''

	parseRSS:(data)->
		title: data.title
		entry: @parseEntry(e,data.title) for e in _.flatten([data.item])


