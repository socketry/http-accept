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

require 'http/accept/charsets'

RSpec.describe HTTP::Accept::Charsets::Charset do
	it "should have default quality_factor of 1.0" do
		charset = HTTP::Accept::Charsets::Charset.new('utf-8', nil)
		expect(charset.quality_factor).to be == 1.0
	end
end

RSpec.describe HTTP::Accept::Charsets do
	it "should parse basic header" do
		charsets = HTTP::Accept::Charsets.parse("utf-8, iso-8859-1;q=0.5, windows-1252;q=0.25")
		
		expect(charsets.length).to be == 3
		
		expect(charsets[0].charset).to be == "utf-8"
		expect(charsets[0].quality_factor).to be == 1.0
		
		expect(charsets[1].charset).to be == "iso-8859-1"
		expect(charsets[1].quality_factor).to be == 0.5
		
		expect(charsets[2].charset).to be == "windows-1252"
		expect(charsets[2].quality_factor).to be == 0.25
	end
	
	it "should order based on quality factor" do
		charsets = HTTP::Accept::Charsets.parse("windows-1252;q=0.25, iso-8859-1;q=0.5, utf-8")
		expect(charsets.collect(&:charset)).to be == %w{utf-8 iso-8859-1 windows-1252}
		
		charsets = HTTP::Accept::Charsets.parse("us-ascii,iso-8859-1;q=0.8,windows-1252;q=0.6,utf-8")
		expect(charsets.collect(&:charset)).to be == %w{us-ascii utf-8 iso-8859-1 windows-1252}
	end
	
	it "should accept wildcard charset" do
		charsets = HTTP::Accept::Charsets.parse("*;q=0")
		
		expect(charsets[0].charset).to be == "*"
		expect(charsets[0].quality_factor).to be == 0
	end
	
	it "should preserve relative order" do
		charsets = HTTP::Accept::Charsets.parse("utf-8, iso-8859-1;q=0.5, windows-1252;q=0.5")
		
		expect(charsets[0].charset).to be == "utf-8"
		expect(charsets[1].charset).to be == "iso-8859-1"
		expect(charsets[2].charset).to be == "windows-1252"
	end
	
	it "should not accept invalid input" do
		[
			"utf-8;f=1", "us-ascii;utf-8",
			";", ","
		].each do |text|
			expect{HTTP::Accept::Charsets.parse(text)}.to raise_error(HTTP::Accept::ParseError)
		end
	end
	
	describe "browser_preferred_charsets" do
		it "should parse a non-blank header" do
			env = {HTTP::Accept::Charsets::HTTP_ACCEPT_CHARSET => "utf-8, iso-8859-1, sdch"}
			charsets = HTTP::Accept::Charsets.browser_preferred_charsets(env)
			expect(charsets.length).to be == 3
			expect(charsets[0].charset).to be == "utf-8"
			expect(charsets[1].charset).to be == "iso-8859-1"
			expect(charsets[2].charset).to be == "sdch"
		end
		
		it "should treat a blank header as an error" do
			env = {HTTP::Accept::Charsets::HTTP_ACCEPT_CHARSET => ""}
			expect{HTTP::Accept::Charsets.browser_preferred_charsets(env)}.to raise_error(HTTP::Accept::ParseError)
		end
		
		it "should treat a missing header as '*'" do
			env = {}
			charsets = HTTP::Accept::Charsets.browser_preferred_charsets(env)
			expect(charsets.length).to be == 1
			expect(charsets[0].charset).to be == "*"
		end
	end
end
