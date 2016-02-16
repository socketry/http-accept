#!/usr/bin/env rspec

# Copyright, 2016, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'http/accept/media_types'

module HTTP::Accept::MediaTypesSpec
	describe HTTP::Accept::MediaTypes do
		it "should parse basic header with multiple parameters" do
			media_types = HTTP::Accept::MediaTypes.parse("text/html;q=0.5, application/json")
			
			expect(media_types[0].mime_type).to be == "application/json"
			expect(media_types[0].parameters).to be == {}
			expect(media_types[1].mime_type).to be == "text/html"
			expect(media_types[1].parameters).to be == {'q' => '0.5'}
		end
		
		it "should parse basic header with multiple parameters" do
			media_types = HTTP::Accept::MediaTypes.parse("text/html;q=0.5, application/json;q=1.0; version=1")
			
			expect(media_types[0].mime_type).to be == "application/json"
			expect(media_types[0].parameters).to be == {'q' => '1.0', 'version' => '1'}
			expect(media_types[1].mime_type).to be == "text/html"
			expect(media_types[1].parameters).to be == {'q' => '0.5'}
		end
		
		it "should parse quoted strings correctly" do
			# Many parsers use something like `header_value.split(',')` and you know from that point it's downhill.
			media_types = HTTP::Accept::MediaTypes.parse("foo/bar;key=\"A,B,C\"")
			
			expect(media_types.count).to be == 1
			expect(media_types[0].mime_type).to be == "foo/bar"
			expect(media_types[0].parameters).to be == {'key' => "A,B,C"}
		end
		
		
		it "should not accept invalid input" do
			[
				"foo",
				"foo/",
				"foo/bar;",
				"foo/bar;x",
				"foo/bar;x=",
				"foo/bar;x=\"",
				"foo/bar;x=\"baz",
				"foo/bar;x=",
				";foo/bar",
				",",
			].each do |text|
				expect{HTTP::Accept::MediaTypes.parse(text)}.to raise_error(HTTP::Accept::ParseError)
			end
		end
	end
	
	describe HTTP::Accept::MediaTypes::Map do
		Converter = Struct.new(:content_type)
		
		let(:text_html_converter) {Converter.new("text/html")}
		let(:text_plain_converter) {Converter.new("text/plain")}
		
		it "should give the correct converter when specified completely" do
			subject << text_html_converter
			subject << text_plain_converter
			
			media_types = HTTP::Accept::MediaTypes.parse("text/plain, text/*, */*")
			expect(subject.for(media_types).first).to be == text_plain_converter
			
			media_types = HTTP::Accept::MediaTypes.parse("text/html, text/*, */*")
			expect(subject.for(media_types).first).to be == text_html_converter
		end
		
		it "should match the wildcard subtype converter" do
			subject << text_html_converter
			subject << text_plain_converter
			
			media_types = HTTP::Accept::MediaTypes.parse("text/*, */*")
			expect(subject.for(media_types).first).to be == text_html_converter
			
			media_types = HTTP::Accept::MediaTypes.parse("*/*")
			expect(subject.for(media_types).first).to be == text_html_converter
		end
		
		it "should fail to match if no media types match" do
			subject << text_plain_converter
			
			expect(subject.for(["application/json"])).to be nil
		end
		
		it "should fail to match if no media types specified" do
			expect(subject.for(["text/*", "*/*"])).to be nil
		end
		
		it "should freeze converters" do
			subject << text_html_converter
			
			subject.freeze
			
			expect(text_html_converter).to be_frozen
		end
	end
end