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

controller.EntryListCtrl = ($scope,$http)->

	$scope.entries = []

	$http.get("/latest/json")
		.success (data,status)->
			$scope.entries = data
		.error (data,status)->

		$scope.plusMinus = (bool)->
			if(bool) then "minus" else "plus"

	$scope.encode = (url)->
		encodeURIComponent url

	scope:$scope