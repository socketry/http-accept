# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2019, by Samuel Williams.

require 'http/accept/media_types'
require 'http/accept/media_types/map'
require 'http/accept/content_type'

describe HTTP::Accept::MediaTypes::Map do
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
	
	let(:map) {subject.new}
	
	it "should give the correct converter when specified completely" do
		map << text_html_converter
		map << text_plain_converter
		
		media_types = HTTP::Accept::MediaTypes.parse("text/plain, text/*, */*")
		expect(map.for(media_types).first).to be == text_plain_converter
		
		media_types = HTTP::Accept::MediaTypes.parse("text/html, text/*, */*")
		expect(map.for(media_types).first).to be == text_html_converter
	end
	
	it "should match the wildcard subtype converter" do
		map << text_html_converter
		map << text_plain_converter
		
		media_types = HTTP::Accept::MediaTypes.parse("text/*, */*")
		expect(map.for(media_types).first).to be == text_html_converter
		
		media_types = HTTP::Accept::MediaTypes.parse("*/*")
		expect(map.for(media_types).first).to be == text_html_converter
	end
	
	it "should fail to match if no media types match" do
		map << text_plain_converter
		
		expect(map.for(["application/json"])).to be_nil
	end
	
	it "should fail to match if no media types specified" do
		expect(map.for(["text/*", "*/*"])).to be_nil
	end
	
	it "should freeze converters" do
		map << text_html_converter
		
		map.freeze
		
		expect(text_html_converter).to be(:frozen?)
	end
	
	it "should assign and retrive media ranges" do
		map["*/*"] = :test
		
		expect(map["*/*"]).to be == :test
	end
end
