angular.module('rss', ['angular-gestures'])

angular.module('rss').directive 'ngEnter', ->
	(scope, element, attrs)->
		element.bind "keydown keypress", (event)->
			if(event.which == 13)
				scope.$apply ->
					scope.$eval(attrs.ngEnter)
				event.preventDefault()
