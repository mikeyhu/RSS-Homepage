exports.createFeed = (aURL,someTags)->
	URL:aURL
	tags:someTags

exports.createFeedDelimited = (aURL,someTags)->
	URL:aURL
	tags:e.trim() for e in someTags.split(",")