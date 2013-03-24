controller = exports ? this

states = {
	NEW:"new"
	ARCHIVED:"archived"
	STARRED:"starred"
}

controller.EntryListCtrl = ($scope,$http)->

	$scope.entries = []
	if $http
		$http.get("/latest/json")
			.success (data,status)->
				$scope.entries = data
			.error (data,status)->

	#internal functions
	$scope.changeState = (entry,state)->
		ignoreOutput = (data,status)->
		
		if $http
			$http.get("/changeState?state=" + state + "&id=" + $scope.encode(entry.id))
				.success(ignoreOutput)
				.error(ignoreOutput)

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

	# Template helpers
	$scope.encode = (url)->
		encodeURIComponent url

	$scope.plusMinus = (open)->
		if open then "minus" else "plus"

	$scope.status = (state)->
		if state==states.STARRED then "" else "-empty" 

	scope:$scope