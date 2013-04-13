controller = exports ? this

states = {
	NEW:"new"
	ARCHIVED:"archived"
	STARRED:"starred"
}

controller.EntryListCtrl = ($scope,$http)->

	$scope.tags = [
		{name:"All"},
		{name:"Technology"},
		{name:"News"},
		{name:"Sport"}
	]
	$scope.selectedTag = $scope.tags[0]

	$scope.entries = []

	#internal functions
	$scope.refreshEntries = ()->
		if $http
			url = if $scope.selectedTag.name=="All" then "/latest/json" else "/latestByTag/json?tag=" + $scope.selectedTag.name
			$http.get(url)
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

	$scope.refreshEntries()

	scope:$scope