feed= require '../../../src/server/Feed.coffee'
expect = (require 'chai').expect

describe 'A Feed', ->
	it 'should have a URL', ->
		f = feed.createFeed("http://URL")
		expect(f.URL).to.equal "http://URL"

	it 'should have some tags', ->
		f = feed.createFeed("http://URL",["Technology","News"])
		expect(f.tags).to.eql ["Technology","News"]

	it 'should be able to turn a tag into an array', ->
		f = feed.createFeedDelimited("http://URL","Technology")
		expect(f.tags).to.eql ["Technology"]

	it 'should be able to split comma delimited tags', ->
		f = feed.createFeedDelimited("http://URL","Technology,News")
		expect(f.tags).to.eql ["Technology","News"]
		