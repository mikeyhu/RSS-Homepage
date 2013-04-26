controller = exports ? this

states = {
	NEW:"new"
	ARCHIVED:"archived"
	STARRED:"starred"
}

controller.EntryListCtrl = ($scope,$http)->

	$scope.tags = [
		{group:"Types",name:"All",url:"/latest/json"}
	]
	$scope.selectedTag = $scope.tags[0]

	$scope.getTags = ()->
		if $http
			$http.get("/tags/json")
				.success (data,status)->
					tags = ( {group:"Tags",name:t} for t in data)
					$scope.tags = $scope.tags.concat(tags)

	$scope.entries = []

	#internal functions
	$scope.refreshEntries = ()->
		if $http
			url = if $scope.selectedTag.group=="Types" then $scope.selectedTag.url else "/latestByTag/json?tag=" + $scope.selectedTag.name
			$http.get($scope.cacheBust url)
				.success (data,status)->
					$scope.entries = data
				.error (data,status)->

	$scope.changeState = (entry,state)->
		ignoreOutput = (data,status)->

		if $http
			$http.get("/changeState?state=" + state + "&id=" + $scope.encode(entry.id))
				.success(ignoreOutput)
				.error(ignoreOutput)

	$scope.findNew = ()->
		entry for entry in $scope.entries when entry.state==states.NEW

	$scope.cacheBust = (url)-> 
		start =	if url.indexOf("?") > 1 then "&" else "?"		
		"#{url}#{start}_=#{Math.random() * 5}"	

	#events
	$scope.remove = (index)->
		entry = $scope.entries[index]
		$scope.entries.splice index,1
		$scope.changeState entry,states.ARCHIVED


	$scope.star = (index)->
		entry = $scope.entries[index]
		if entry.state==states.STARRED
			entry.state=states.NEW
		else
			entry.state=states.STARRED
		$scope.changeState entry,entry.state

	$scope.read = (index)->
		$scope.entries.splice index,1
		true


	$scope.archiveAllNew = ()->
		newIds = (entry.id for entry in $scope.findNew())
		console.log newIds
		if $http
			$http.post("/changeMultipleStates?state=#{states.ARCHIVED}",newIds)
				.success (data,status)->
					$scope.refreshEntries()
				.error (data,status)->


	# Template helpers
	$scope.encode = (url)->
		encodeURIComponent url

	$scope.plusMinus = (open)->
		if open then "minus" else "plus"

	$scope.status = (state)->
		if state==states.STARRED then "" else "-empty" 

	$scope.getTags()
	$scope.refreshEntries()

	scope:$scope