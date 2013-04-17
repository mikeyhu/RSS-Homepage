webserver = require '../../../src/server/Webserver.coffee'
mongostore = require '../../../src/server/MongoStore.coffee'
feedstore = require '../../../src/server/FeedStore.coffee'
http = require 'http'
urlparser = require 'url'
expect = (require 'chai').expect
moment = require 'moment'

after = andAlso = require '../shared/Feed_steps.coffee'

port = 5550
url = "http://localhost:#{port}/"

connectionString = "mongodb://localhost:27000/feeds"

database = mongostore.createMongostore(connectionString)
feedsDB = feedstore.createFeedstore(connectionString)

twentyEntries = ({title:"title #{num}",id:"id#{num}",date:moment().subtract('minutes',20-num),tags:[if num < 10 then "News" else "Technology"]} for num in [0...20])

webserver.createWebServer(port,connectionString)

requestingSomeJSONFrom=(URL,fun)->
	data=""
	http.get URL, (res) ->
		res.setEncoding('utf8')
		res.on 'data', (chunk)->
			data=data+chunk
		res.on 'end', ()->
			fun(null,JSON.parse(data))
	.on 'error', (e)->	
		console.log("Got error: " + e.message)
		fun(e.message,null)

postingSomeJSON=(URL,input,fun)->

	inputString = JSON.stringify(input)
	headers = {
		'Content-Type': 'application/json',
		'Content-Length': inputString.length
	}

	options = urlparser.parse(URL,true)
	options.method = "POST"
	options.headers = headers
	data=""
	req = http.request options, (res) ->
		res.setEncoding('utf8')
		res.on 'data', (chunk)->
			data=data+chunk
		res.on 'end', ()->
			fun(null,data)
	.on 'error', (e)->  
		console.log("Got error: " + e.message)
		fun(e.message,null)
	req.write inputString
	req.end()


describe 'Requesting the latest entries', () ->
	before (done) ->
		after.insertingSome(twentyEntries).intoThe database,(err,result)->
			done()
	it 'should return JSON of them', (done) ->
		requestingSomeJSONFrom url + "latest/json",(err,data)->
			expect(data[0].title).to.equal "title 19"
			expect(data.length).to.equal 20
			done()

describe 'Requesting the latest entries by tag', () ->
	before (done) ->
		after.insertingSome(twentyEntries).intoThe database,(err,result)->
			done()

	it 'should return JSON of them', (done) ->
		requestingSomeJSONFrom url + "latestByTag/json?tag=News",(err,data)->
			expect(data[0].title).to.equal "title 9"
			expect(data.length).to.equal 10
			done()

describe 'Updating multiple entries',(done)->
	before (done)->
		after.clearingDataFromThe database,(result)->
			after.insertingSome(twentyEntries).intoThe database,(err,result)->
				done()

	it 'should return the JSON of only new entries', (done)->
		postingSomeJSON url + "changeMultipleStates?state=archived",["id1","id2","id3"],(err,result)->
			throw err if err
			requestingSomeJSONFrom url + "latest/json",(err,data)->
				expect(data.length).to.equal 17
				done()

describe 'Requesting a list of feeds', (done)->
	before (done)->
		feeds = [
			{URL: "http://feeds.bbci.co.uk/news/rss.xml",tags:["News"]},
			{URL: "http://www.theverge.com/rss/index.xml",tags:["Technology"]}
		]
		after.addingSomeFeeds(feeds).intoThe feedsDB,(err,result)->
			done()

	it 'should return JSON of them', (done)->
		requestingSomeJSONFrom url + "feeds/json",(err,data)->
			expect(data[0].URL).to.equal "http://feeds.bbci.co.uk/news/rss.xml"
			expect(data[1].URL).to.equal "http://www.theverge.com/rss/index.xml"
			done()

describe 'Adding a feed', (done)->
	before (done)->
		feedsDB.clear (err,result)->
			done()
	it 'should contain a feed',(done)->
		http.get url + "insertFeed?URL=abc&tags=def",(err,result)-> 
			requestingSomeJSONFrom url + "feeds/json",(err,data)->
				expect(data.length).to.equal 1
				expect(data[0].URL).to.equal "abc"
				expect(data[0].tags).to.eql ["def"]
				done()

describe 'Removing a feed', (done)->
	before (done)->
		feedsDB.clear (err,result)->
			done()
	it 'should contain a feed',(done)->
		http.get url + "insertFeed?URL=abc&tags=def",(err,result)->
			requestingSomeJSONFrom url + "feeds/json",(err,data)->
				expect(data.length).to.equal 1
				http.get url + "removeFeed?URL=abc",(err,result)->
					requestingSomeJSONFrom url + "feeds/json",(err,data)->
						expect(data.length).to.equal 0
						done()
