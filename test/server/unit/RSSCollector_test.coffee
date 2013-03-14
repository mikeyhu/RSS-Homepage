collector = require '../../../src/server/RSSCollector.coffee'
expect = (require 'chai').expect

FakeRSS = "http://localhost:7777/rss.xml"

describe 'A RSS collector', ->
	beforeEach () ->
		@collector = collector.createRSSCollector()

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
		@collector.parseRSS data,(err,result)->
			expect(err).to.be.null
			expect(result.title,"title").to.equal("BBC News - Home")
			done()
	it 'should be able to retrieve and parse some XML', (done)->
		@collector.requestRSS FakeRSS,(err,result)->
			expect(err,err).to.be.null
			expect(result,"result").to.exist
			done()