# frozen_string_literal: true
#
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
require 'http/accept/media_types/map'
require 'http/accept/content_type'

RSpec.describe HTTP::Accept::MediaTypes::Map do
	let(:converter) do
		Struct.new(:content_type) do
			def split(*args)
				self.content_type.split(*args)
			end
		end
	end
	
	let(:text_html_converter) {converter.new("text/html")}
	
	let(:text_plain_content_type) {HTTP::Accept::ContentType.new("text", "plain", charset: 'utf-8')}
	let(:text_plain_converter) {converter.new(text_plain_content_type)}
	
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
	
	it "should assign and retrive media ranges" do
		subject["*/*"] = :test
		
		expect(subject["*/*"]).to be == :test
	end
end
