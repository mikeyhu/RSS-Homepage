collector = require '../../../src/server/FeedCollector.coffee'
feed = require '../../../src/server/Feed.coffee'
expect = (require 'chai').expect

fakeRSS = "http://localhost:7777/rss.xml"

describe 'A Feed collector', ->
	beforeEach () ->
		@collector = collector.createFeedCollector()

	it 'should be able to parse an RSS Feed', (done)->
		data = 
			"""
			<?xml version="1.0" encoding="UTF-8"?>
			<?xml-stylesheet title="XSL_formatting" type="text/xsl" href="/shared/bsp/xsl/rss/nolsol.xsl"?>
			<rss xmlns:media="http://search.yahoo.com/mrss/" xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">  
			  <channel> 
			    <title>BBC News - Home</title>  
			    <link>http://www.bbc.co.uk/news/#sa-ns_mchannel=rss&amp;ns_source=PublicRSS20-sa</link>  
			    <atom:link href="http://feeds.bbci.co.uk/news/rss.xml" rel="self" type="application/rss+xml"/>  
			    <item> 
			      <title>Cameron halts press regulation talks</title>  
			      <description>Prime Minister David Cameron calls a halt to cross-party talks on press regulation, sparking anger from party leaders and victims of media intrusion.</description>  
			      <link>http://www.bbc.co.uk/news/uk-21785611#sa-ns_mchannel=rss&amp;ns_source=PublicRSS20-sa</link>  
			      <guid isPermaLink="false">http://www.bbc.co.uk/news/uk-21785611</guid>  
			    </item>  
			    <item> 
			      <title>Pope sounds warning to Catholics</title>  
			      <description>Newly elected Pope Francis warns that the Catholic Church will be just "a compassionate NGO" unless it focuses on its primary, religious mission.</description>  
			      <link>http://www.bbc.co.uk/news/world-europe-21793224#sa-ns_mchannel=rss&amp;ns_source=PublicRSS20-sa</link>  
			      <guid isPermaLink="false">http://www.bbc.co.uk/news/world-europe-21793224</guid>  
			    </item>  
			  </channel> 
			</rss>
			"""
		@collector.parseFeed data,(err,result)->
			expect(err).to.be.null
			expect(result.title,"title").to.equal("BBC News - Home")
			expect(result.entry[0].title).to.equal("Cameron halts press regulation talks")
			expect(result.entry[1].link).to.equal("http://www.bbc.co.uk/news/world-europe-21793224#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa")
			done()

	it 'should be able to retrieve and parse some RSS XML', (done)->
		@collector.requestFeed fakeRSS,(err,result)->
			expect(err,err).to.be.null
			expect(result,"result").to.exist
			done()

	it 'should be able to parse some Atom XML', (done)->
		data = 
			"""
			<?xml version="1.0" encoding="utf-8"?>
			<feed xmlns="http://www.w3.org/2005/Atom">
        		<title>Example Feed</title>
        		<subtitle>Insert witty or insightful remark here</subtitle>
        		<link href="http://example.org/"/>
        		<updated>2003-12-13T18:30:02Z</updated>
        		<author>
                	<name>John Doe</name>
                	<email>johndoe@example.com</email>
        		</author>
        		<id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>
	        	<entry>
	                <title>Atom-Powered Robots Run Amok</title>
	                <link href="http://example.org/2003/12/13/atom03"/>
	                <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
	                <updated>2003-12-13T18:30:02Z</updated>
	                <summary>Some text.</summary>
	        	</entry>
			</feed>
			"""
		@collector.parseFeed data,(err,result)->
			expect(err).to.be.null
			expect(result.title,"title").to.equal("Example Feed")
			expect(result.entry[0].title).to.equal("Atom-Powered Robots Run Amok")
			expect(result.entry[0].link).to.equal("http://example.org/2003/12/13/atom03")
			done()

	it 'should convert an atom entry link from attribute to element', ()->
		entry = 
			title:"abc"
			link:{"$": {"href": "http://example.org/2003/12/13/atom03"}}
			updated: "2013-03-21T16:09:59.852Z",
			id:"def"

		expect(@collector.parseEntry entry).to.eql
			title:"abc"
			link:"http://example.org/2003/12/13/atom03"
			id:"def"
			date: "2013-03-21T16:09:59.852Z"
#			image:""
			summary:""
			tags:[]

	it 'should be able to retrieve a feed when provided with a Feed object', (done)->
		fakeFeed = feed.createFeed(fakeRSS,["News"])
		@collector.collectFeed fakeFeed,(err,result)->
			expect(err).to.be.null
			expect(result.title).to.equal "BBC News - Home"
			expect(result.entry[0].title).to.equal "Cameron halts press regulation talks"
			expect(result.entry[0].date).to.equal "2013-03-14T19:55:45.000Z"
			expect(result.entry[0].tags).to.eql ["News"]
			done()
