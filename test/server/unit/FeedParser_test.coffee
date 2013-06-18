dom = require('xmldom').DOMParser
parser = require '../../../src/server/FeedParser.coffee'
feed = require '../../../src/server/Feed.coffee'
expect = (require 'chai').expect

fakeRSS = "http://localhost:7777/rss.xml"

describe 'A Feed collector', ->

	it 'should be able to retrieve a string using an xpath', ->
		doc = new dom().parseFromString("<abc>some data</abc>")
		fp = parser.createFeedParser()
		expect(fp.getString("/abc/text()",doc)).to.equal("some data")
		expect(fp.getString("/bcd/text()",doc)).to.equal("") 	

	it 'should be able to retrieve a string with an & in using an xpath and decode it correctly', ->
		doc = new dom().parseFromString("<abc>some&lt; &amp; &gt;data</abc>")
		fp = parser.createFeedParser()
		expect(fp.getString("/abc/text()",doc)).to.equal("some< & >data")
		expect(fp.getString("/bcd/text()",doc)).to.equal("")

	it 'should be able to retrieve an attribute using an xpath', ->
		doc = new dom().parseFromString('<abc><def ghi="jkl"/></abc>')
		fp = parser.createFeedParser()
		expect(fp.getAttribute("/abc/def/@ghi",doc)).to.equal("jkl")
		expect(fp.getAttribute("/abc/@def",doc)).to.equal("")

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
				  <pubDate>Thu, 14 Mar 2013 19:55:45 GMT</pubDate>
				  <media:thumbnail width="66" height="49" url="http://news.bbcimg.co.uk/media/images/66397000/jpg/_66397155_comp_clegg_mili_cam.jpg"/>  
				  <media:thumbnail width="144" height="81" url="http://news.bbcimg.co.uk/media/images/66397000/jpg/_66397156_comp_clegg_mili_cam.jpg"/>   
				</item>  
				<item> 
				  <title>Pope sounds warning to Catholics</title>  
				  <description>Newly elected Pope Francis warns that the Catholic Church will be just "a compassionate NGO" unless it focuses on its primary, religious mission.</description>  
				  <link>http://www.bbc.co.uk/news/world-europe-21793224#sa-ns_mchannel=rss&amp;ns_source=PublicRSS20-sa</link>  
				  <media:content height="84" lang="" type="image/jpeg" width="140" url="http://static.guim.co.uk/sys-images/Guardian/Pix/pictures/2013/6/18/1371564440080/us-afghanistan-005.jpg">
				  <pubDate>Thu, 14 Mar 2013 19:55:45 GMT</pubDate> 
				</item>  
			  </channel> 
			</rss>
			"""
		fp = parser.createFeedParser()
		fp.parseFeed data,(err,result)->
			expect(err).to.be.null
			expect(result.entry.length).to.equal(2)
			expect(result.title,"title").to.equal("BBC News - Home")
			expect(result.entry[0].title).to.equal("Cameron halts press regulation talks")
			expect(result.entry[0].summary).to.equal("Prime Minister David Cameron calls a halt to cross-party talks on press regulation, sparking anger from party leaders and victims of media intrusion.")
			expect(result.entry[0].id).to.equal("http://www.bbc.co.uk/news/uk-21785611")
			expect(result.entry[0].image).to.equal("http://news.bbcimg.co.uk/media/images/66397000/jpg/_66397155_comp_clegg_mili_cam.jpg")
			expect(result.entry[0].date).to.equal("2013-03-14T19:55:45.000Z")
			expect(result.entry[0].feedName).to.equal("BBC News - Home")
			expect(result.entry[1].id).to.equal("http://www.bbc.co.uk/news/world-europe-21793224#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa")
			expect(result.entry[1].link).to.equal("http://www.bbc.co.uk/news/world-europe-21793224#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa")
			expect(result.entry[1].image).to.equal("http://static.guim.co.uk/sys-images/Guardian/Pix/pictures/2013/6/18/1371564440080/us-afghanistan-005.jpg")
			done()

	it 'should be able to parse an RSS Feed', (done)->
		data = 
			"""
			<?xml version="1.0" encoding="UTF-8"?>
			<?xml-stylesheet title="XSL_formatting" type="text/xsl" href="/shared/bsp/xsl/rss/nolsol.xsl"?>
			<rss xmlns:media="http://search.yahoo.com/mrss/" xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">  
			  <channel> 
				<title>BBC News - Home</title>    
				<item> 
				  <title>Cameron halts press regulation talks</title>  
				  <description>Prime Minister David Cameron calls a halt to cross-party talks on press regulation, sparking anger from party leaders and victims of media intrusion.</description>  
				  <link>http://www.bbc.co.uk/news/uk-21785611#sa-ns_mchannel=rss&amp;ns_source=PublicRSS20-sa</link>  
				  <guid isPermaLink="false">http://www.bbc.co.uk/news/uk-21785611</guid>
				</item>   
			  </channel> 
			</rss>
			"""
		fp = parser.createFeedParser(feed.createFeed("http://www.domain.com/abc",["News"]))
		fp.parseFeed data,(err,result)->
			expect(result.entry[0].title).to.equal("Cameron halts press regulation talks")
			expect(result.entry[0].hostName).to.equal("www.domain.com")
			expect(result.entry[0].tags).to.eql ["News"]
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
		fp = parser.createFeedParser()
		fp.parseFeed data,(err,result)->
			expect(err).to.be.null
			expect(result.title,"title").to.equal("Example Feed")
			expect(result.entry[0].title).to.equal("Atom-Powered Robots Run Amok")
			expect(result.entry[0].link).to.equal("http://example.org/2003/12/13/atom03")
			expect(result.entry[0].date).to.equal("2003-12-13T18:30:02.000Z")
			expect(result.entry[0].feedName).to.equal("Example Feed")
			done()

	it 'should return an error if it cannot recognise the feed type',->
		fp = parser.createFeedParser()
		fp.parseFeed "<myfeed>dfsdfsd</myfeed>",(err,result)->
			expect(err).to.equal("Unable to parse feed, not recognised as RSS or Atom.")
			expect(result).to.be.null

	it 'should be able to return the first of possible values that is not empty',->
		fp = parser.createFeedParser()
		expect(fp.oneOf("a")).to.equal("a")
		expect(fp.oneOf("","b")).to.equal("b")
		expect(fp.oneOf("","","c","d")).to.equal("c")
		expect(fp.oneOf("","","","")).to.equal("")