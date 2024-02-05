# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016, by Matthew Kerwin.
# Copyright, 2017-2019, by Samuel Williams.

require 'http/accept/encodings'

RSpec.describe HTTP::Accept::Encodings::ContentCoding do
	it "should have default quality_factor of 1.0" do
		encoding = HTTP::Accept::Encodings::ContentCoding.new('gzip', nil)
		expect(encoding.quality_factor).to be == 1.0
	end
end

RSpec.describe HTTP::Accept::Encodings do
	it "should parse basic header" do
		encodings = HTTP::Accept::Encodings.parse("gzip, deflate;q=0.5, identity;q=0.25")
		
		expect(encodings.length).to be == 3
		
		expect(encodings[0].encoding).to be == "gzip"
		expect(encodings[0].quality_factor).to be == 1.0
		
		expect(encodings[1].encoding).to be == "deflate"
		expect(encodings[1].quality_factor).to be == 0.5
		
		expect(encodings[2].encoding).to be == "identity"
		expect(encodings[2].quality_factor).to be == 0.25
	end
	
	it "should order based on quality factor" do
		encodings = HTTP::Accept::Encodings.parse("identity;q=0.25, deflate;q=0.5, gzip")
		expect(encodings.collect(&:encoding)).to be == %w{gzip deflate identity}
		
		encodings = HTTP::Accept::Encodings.parse("br,deflate;q=0.8,identity;q=0.6,gzip")
		expect(encodings.collect(&:encoding)).to be == %w{br gzip deflate identity}
	end
	
	it "should accept wildcard encoding" do
		encodings = HTTP::Accept::Encodings.parse("*;q=0")
		
		expect(encodings[0].encoding).to be == "*"
		expect(encodings[0].quality_factor).to be == 0
	end
	
	it "should preserve relative order" do
		encodings = HTTP::Accept::Encodings.parse("br, gzip;q=0.5, deflate;q=0.5")
		
		expect(encodings[0].encoding).to be == "br"
		expect(encodings[1].encoding).to be == "gzip"
		expect(encodings[2].encoding).to be == "deflate"
	end
	
	it "should not accept invalid input" do
		[
			"gzip;f=1", "br;gzip",
			";", ","
		].each do |text|
			expect{HTTP::Accept::Encodings.parse(text)}.to raise_error(HTTP::Accept::ParseError)
		end
	end
	
	describe "browser_preferred_content_codings" do
		it "should parse a non-blank header" do
			env = {HTTP::Accept::Encodings::HTTP_ACCEPT_ENCODING => "gzip, deflate, sdch"}
			encodings = HTTP::Accept::Encodings.browser_preferred_content_codings(env)
			expect(encodings.length).to be == 3
			expect(encodings[0].encoding).to be == "gzip"
			expect(encodings[1].encoding).to be == "deflate"
			expect(encodings[2].encoding).to be == "sdch"
		end
		
		it "should treat a blank header as 'identity'" do
			env = {HTTP::Accept::Encodings::HTTP_ACCEPT_ENCODING => ""}
			encodings = HTTP::Accept::Encodings.browser_preferred_content_codings(env)
			expect(encodings.length).to be == 1
			expect(encodings[0].encoding).to be == "identity"
		end
		
		it "should treat a missing header as '*'" do
			env = {}
			encodings = HTTP::Accept::Encodings.browser_preferred_content_codings(env)
			expect(encodings.length).to be == 1
			expect(encodings[0].encoding).to be == "*"
		end
	end
end
