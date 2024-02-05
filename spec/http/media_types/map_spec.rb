# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2019, by Samuel Williams.

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
