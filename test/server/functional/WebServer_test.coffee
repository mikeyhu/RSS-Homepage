webserver = require '../../../src/server/WebServer.coffee'
mongostore = require '../../../src/server/MongoStore.coffee'
http = require 'http'
expect = (require 'chai').expect
moment = require 'moment'

after = andAlso = require '../shared/Feed_steps.coffee'

port = 5550
url = "http://localhost:#{port}/"

connectionString = "mongodb://localhost:27000/feeds"

database = mongostore.createMongostore(connectionString)

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