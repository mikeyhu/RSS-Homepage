controller = exports ? this

controller.SearchCtrl = ($scope,$http)->

	$scope.getParameterByName = (name)-> 
		name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
		regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
		results = regex.exec(location.search)
		if results == null then "" else decodeURIComponent(results[1].replace(/\+/g, " "))

	$scope.entries = []
	qsTerm = $scope.getParameterByName("term")
	console.log "term:" + qsTerm
	$scope.searchTerm = qsTerm ? ""

	#internal functions
	$scope.isEmpty = ->
		$scope.entries.length == 0

	$scope.newSearch = ()->
		$scope.search($scope.searchTerm)

	$scope.search = (term)->
		console.log "New Search for : #{term}"
		$scope.entries = []
		if $http
			url = "/search/json?term=#{term}"
			$http.get($scope.cacheBust url)
				.success (data,status)->
					$scope.entries = data
				.error (data,status)->

	$scope.cacheBust = (url)-> 
		start =	if url.indexOf("?") > 1 then "&" else "?"		
		"#{url}#{start}_=#{Math.random() * 5}"

	$scope.plusMinus = (open)->
		if open then "minus" else "plus"

	if $scope.searchTerm!="" then $scope.newSearch()

	scope:$scope



controller.SearchFormCtrl = ($scope,$window)->
	$scope.searchTerm = ""

	$scope.search = ->
		$window.location.href = "/search?term=#{$scope.searchTerm}"

	scope:$scope