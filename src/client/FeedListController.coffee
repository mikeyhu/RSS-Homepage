controller = exports ? this

controller.FeedListCtrl = ($scope,$http)->
	$scope.newURL = ''
	$scope.newTags = ''

	$scope.feeds = []

	$scope.ignoreOutput = (data)-> console.log data

	$scope.newFeed = ()-> 

	$scope.refreshFeeds = ()->
		if $http
			$http.get("/feeds/json")
				.success (data,status)->
					$scope.feeds = data
				.error (data,status)->

	$scope.addFeed = ()->
		feed = {URL:$scope.newURL,tags:[$scope.newTags]}
		$scope.newURL = ''
		$scope.newTags = ''

		$scope.feeds.push(feed)

		if $http
			$http.get("/insertFeed?URL=" + $scope.encode(feed.URL) + "&tags=" + $scope.encode(feed.tags))
				.success(ignoreOutput)
				.error(ignoreOutput)

	$scope.encode = (data)->
		encodeURIComponent data

	$scope.removeFeed = (index)->
		$scope.feeds.splice index,1

	$scope.refreshFeeds()

	scope:$scope

