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

	ignoreOutput = (data,status)->

	$scope.encode = (url)->
		encodeURIComponent url

	$scope.plusMinus = (open)->
		if open then "minus" else "plus"

	$scope.remove = (index)->
		entry = $scope.entries[index]
		$scope.entries.splice index,1
		if $http
			$http.get("/changeState?state=" + states.ARCHIVED + "&id=" + $scope.encode(entry.id))
				.success(ignoreOutput)
				.error(ignoreOutput)

	$scope.star = (index)->
		entry = $scope.entries[index]
		if entry.state==states.STARRED
			entry.state=states.NEW
		else
			entry.state=states.STARRED
		if $http
			$http.get("/changeState?state="+ entry.state + "&id=" + $scope.encode(entry.id))
				.success(ignoreOutput)
				.error(ignoreOutput)

	$scope.status = (state)->
		if state==states.STARRED then "" else "-empty" 


	scope:$scope