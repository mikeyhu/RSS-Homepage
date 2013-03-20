feed= require '../../../src/server/Feed.coffee'
expect = (require 'chai').expect

describe 'A Feed', ->
	it 'should have a URL', ->
		f = feed.createFeed("http://URL")
		expect(f.URL).to.equal "http://URL"

	it 'should have some tags', ->
		f = feed.createFeed("http://URL",["Technology","News"])
		expect(f.tags).to.eql ["Technology","News"]
		