controller = exports ? this

controller.FeedListCtrl = ($scope)->
	$scope.feedURL = ''

	$scope.listData = [
		{url: "http://feeds.bbci.co.uk/news/rss.xml"},
		{url: "http://www.theverge.com/rss/index.xml"}
	]

	$scope.addFeed = ()->
    	$scope.listData.push({url:$scope.feedURL});
    	$scope.feedURL = ''

    scope:$scope

