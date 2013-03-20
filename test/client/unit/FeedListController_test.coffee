controller = require '../../../src/client/FeedListController.coffee'
expect = (require 'chai').expect

describe 'A FeedListCtrl controller', ->
	it 'should be able to list people', ()->
		c = new controller.FeedListCtrl({})
		expect(c.scope.listData).to.eql [
			{url: "http://feeds.bbci.co.uk/news/rss.xml"},
			{url: "http://www.theverge.com/rss/index.xml"}
		]

	it 'should be able to add a person', ()->
		c = new controller.FeedListCtrl({})
		c.scope.feedURL = "http://someother.feed"
		c.scope.addFeed()
		expect(c.scope.listData).to.eql [
			{url: "http://feeds.bbci.co.uk/news/rss.xml"},
			{url: "http://www.theverge.com/rss/index.xml"},
			{url: "http://someother.feed"}
		]
		expect(c.scope.feedURL).to.equal ""

