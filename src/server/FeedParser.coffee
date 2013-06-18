xpath = require 'xpath'
dom = require('xmldom').DOMParser
moment = require 'moment'
url = require 'url'

exports.createFeedParser = (feed)->

	parsedURL:if feed then url.parse(feed.URL,true) else {}

	parseFeed:(data,fun)->
		doc = new dom().parseFromString(data)
		if xpath.select("/rss",doc).length > 0 then @parseRSS(doc,fun)
		else if xpath.select("/feed",doc).length > 0 then @parseAtom(doc,fun)
		else fun("Unable to parse feed, not recognised as RSS or Atom.",null)

	parseRSS:(doc,fun)->
		title = xpath.select("/rss/channel/title/text()",doc).toString()
		items = xpath.select("/rss/channel/item",doc)
		results =
			title : title
			entry : @parseRSSItem(item) for item in items

		fun(null,results)

	parseRSSItem:(item)->
		id:		@oneOf @getString("guid/text()",item),@getString("link/text()",item)
		title:	@getString("title/text()",item)
		link:	@getString("link/text()",item)
		summary:@getString("description/text()",item)	
		image:	@getAttribute("(//*[local-name(.)='thumbnail'])[1]/@url",item)
		date: 	moment(@getString("pubDate/text()",item))?.toJSON()
		tags:	feed?.tags
		hostName:@parsedURL.hostname		

	parseAtom:(doc,fun)->
		title = @getString("/feed/title/text()",doc)
		items = xpath.select("/feed/entry",doc)
		results =
			title : title
			entry : @parseAtomItem(item) for item in items

		fun(null,results)

	parseAtomItem:(item)->
		id:		@oneOf @getString("id/text()",item),@getAttribute("link/@href",item)
		title:	@getString("title/text()",item)
		link:	@getAttribute("link/@href",item)
		summary:@getString("summary/text()",item)
		date: 	moment(@getString("updated/text()",item))?.toJSON()
		tags:	feed?.tags
		hostName:@parsedURL.hostname	

	getString:(path,node)->
		xpath.select(path,node).toString().replace("&amp;","&").replace("&lt;","<").replace("&gt;",">")

	getAttribute:(path,node)->
		attr = xpath.select1(path,node)
		if attr then attr.value.replace("&amp;","&") else ""

	oneOf:(someResults...)->
		(if result!="" then return result) for result in someResults
		""

