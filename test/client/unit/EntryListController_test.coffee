controller = require '../../../src/client/EntryListController.coffee'
expect = (require 'chai').expect

describe 'A EntryListCtrl controller', ->
	it 'should be able to remove entries from a list', ()->
		c = new controller.EntryListCtrl({})
		c.scope.entries = [
			{title:"a",id:"aa"},
			{title:"b",id:"bb"},
			{title:"c",id:"cc"}
		]
		c.scope.remove(1)
		expect(c.scope.entries).to.eql [
			{title:"a",id:"aa"},
			{title:"c",id:"cc"}
		]


