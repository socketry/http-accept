# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2019, by Samuel Williams.

require 'http/accept/media_types'
require 'http/accept/content_type'

RSpec.describe HTTP::Accept::MediaTypes do
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
		
		expect(media_types.size).to be == 1
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
