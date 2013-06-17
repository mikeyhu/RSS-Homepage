url = require 'url'

parsedURL = (URL)-> url.parse(URL,true)

exports.createFeed = (aURL,someTags)->
	URL:aURL
	tags:someTags
	parsedURL:parsedURL(aURL)

exports.createFeedDelimited = (aURL,someTags)->
	URL:aURL
	tags:e.trim() for e in someTags.split(",")
	parsedURL:parsedURL(aURL)
