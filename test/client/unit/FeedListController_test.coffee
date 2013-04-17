controller = require '../../../src/client/FeedListController.coffee'
expect = (require 'chai').expect

describe 'A FeedListCtrl controller', ->
	it 'should be able to add a feed', ()->
		c = new controller.FeedListCtrl({})
		c.scope.feeds = [
			{URL: "http://feeds.bbci.co.uk/news/rss.xml",tags:["News"]},
			{URL: "http://www.theverge.com/rss/index.xml",tags:["Technology"]}
		]
		c.scope.newURL = "http://someother.feed"
		c.scope.newTags = "Another"
		c.scope.addFeed()
		expect(c.scope.feeds).to.eql [
			{URL: "http://feeds.bbci.co.uk/news/rss.xml",tags:["News"]},
			{URL: "http://www.theverge.com/rss/index.xml",tags:["Technology"]},
			{URL: "http://someother.feed",tags:["Another"]}
		]
		expect(c.scope.newURL).to.equal ""
		expect(c.scope.newTags).to.equal ""

	it 'should be able to remove a feed', ()->
		c = new controller.FeedListCtrl({})
		c.scope.feeds = [
			{URL: "http://feeds.bbci.co.uk/news/rss.xml",tags:["News"]},
			{URL: "http://www.theverge.com/rss/index.xml",tags:["Technology"]}
		]
		c.scope.removeFeed(0)
		expect(c.scope.feeds).to.eql [
			{URL: "http://www.theverge.com/rss/index.xml",tags:["Technology"]}
		]