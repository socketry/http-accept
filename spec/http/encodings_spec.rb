#!/usr/bin/env rspec

# Copyright (C) 2016, Matthew Kerwin <matthew@kerwin.net.au>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'http/accept/encodings'

module HTTP::Accept::EncodingsSpec
	describe HTTP::Accept::Encodings::ContentCoding do
		it "should have default quality_factor of 1.0" do
			encoding = HTTP::Accept::Encodings::ContentCoding.new('gzip', nil)
			expect(encoding.quality_factor).to be == 1.0
		end
	end
	
	describe HTTP::Accept::Encodings do
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
			
			if "should treat a blank header as 'identity'" do
				env = {HTTP::Accept::Encodings::HTTP_ACCEPT_ENCODING => ""}
				encodings = HTTP::Accept::Encodings.browser_preferred_content_codings(env)
				expect(encodings.length).to be == 1
				expect(encodings[0].encoding).to be == "identity"
			end
			
			if "should treat a missing header as '*'" do
				env = {}
				encodings = HTTP::Accept::Encodings.browser_preferred_content_codings(env)
				expect(encodings.length).to be == 1
				expect(encodings[0].encoding).to be == "*"
			end
		end
	end
end
