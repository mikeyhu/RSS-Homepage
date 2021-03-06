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

	it 'should be able to star entries in a list', ()->
		c = new controller.EntryListCtrl({})
		c.scope.entries = [
			{title:"a",id:"aa",state:"new"},
			{title:"b",id:"bb",state:"new"},
			{title:"c",id:"cc",state:"new"}
		]
		c.scope.star(1)
		expect(c.scope.entries).to.eql [
			{title:"a",id:"aa",state:"new"},
			{title:"b",id:"bb",state:"starred"},
			{title:"c",id:"cc",state:"new"}
		]

	it 'should be able to find unstarred entries in a list', ()->
		c = new controller.EntryListCtrl({})
		c.scope.entries = [
			{title:"a",id:"aa",state:"new"},
			{title:"b",id:"bb",state:"starred"},
			{title:"c",id:"cc",state:"new"}
		]
		
		expect(c.scope.findNew()).to.eql [
			{title:"a",id:"aa",state:"new"},
			{title:"c",id:"cc",state:"new"}
		]

	it 'should know if the list is empty', ()->
		c = new controller.EntryListCtrl({})
		c.scope.entries = []
		expect(c.scope.isEmpty()).to.equal true

	it 'should know if the list contains items', ()->
		c = new controller.EntryListCtrl({})
		c.scope.entries = [
			{title:"a",id:"aa",state:"new"},
			{title:"b",id:"bb",state:"starred"},
			{title:"c",id:"cc",state:"new"}
		]
		expect(c.scope.isEmpty()).to.equal false


