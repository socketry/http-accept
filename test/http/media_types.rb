# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2019, by Samuel Williams.

require 'http/accept/media_types'
require 'http/accept/content_type'

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
			expect{HTTP::Accept::MediaTypes.parse(text)}.to raise_exception(HTTP::Accept::ParseError)
		end
	end
end

AMediaTypeSelector = Sus::Shared("a media type selector") do |header_value, priorities = nil|
	let(:media_types) {HTTP::Accept::MediaTypes.parse(header_value)}
	
	it "should parse without error" do
		expect{media_types}.not.to raise_exception
	end
	
	it "should have at least one entry" do
		expect(media_types.size).to be > 0
	end
	
	it "should have the correct priorities" do
		expect(media_types).to be == priorities
	end if priorities
end

# Copied from https://greenbytes.de/tech/webdav/rfc7231.html#rfc.section.5.3.2
describe "RFC Example Accept: headers" do
	it_behaves_like AMediaTypeSelector, "audio/*; q=0.2, audio/basic"
	it_behaves_like AMediaTypeSelector, "text/plain; q=0.5, text/html,\n text/x-dvi; q=0.8, text/x-c"
	it_behaves_like AMediaTypeSelector, "text/*, text/plain, text/plain;format=flowed, */*"
	
	it_behaves_like AMediaTypeSelector, "text/*;q=0.3, text/html;q=0.7, text/html;level=1,\n text/html;level=2;q=0.4, */*;q=0.5", [
		HTTP::Accept::MediaTypes::MediaRange.new("text", "html", "level" => "1"),
		HTTP::Accept::MediaTypes::MediaRange.new("text", "html", "q" => "0.7"),
		HTTP::Accept::MediaTypes::MediaRange.new("*", "*", "q" => "0.5"),
		HTTP::Accept::MediaTypes::MediaRange.new("text", "html", "level" => "2", "q" => "0.4"),
		HTTP::Accept::MediaTypes::MediaRange.new("text", "*", "q" => "0.3"),
	]
end

AWildcardMediaRange = Sus::Shared("a wildcard media range") do |env|
	let(:wildcard_media_ranges) {[HTTP::Accept::MediaTypes::WILDCARD_MEDIA_RANGE]}
	
	it "should match any content type" do
		expect(HTTP::Accept::MediaTypes.browser_preferred_media_types(env)).to be == wildcard_media_ranges
	end
end

describe HTTP::Accept::MediaTypes do
	it_behaves_like AWildcardMediaRange, {'HTTP_ACCEPT' => '   */*   '}
	it_behaves_like AWildcardMediaRange, {'HTTP_ACCEPT' => '*/*'}
	
	# http://stackoverflow.com/questions/12130910/how-to-interpret-empty-http-accept-header
	it_behaves_like AWildcardMediaRange, {'HTTP_ACCEPT' => '   '}
	it_behaves_like AWildcardMediaRange, {'HTTP_ACCEPT' => ''}
	
	let(:text_plain_media_range) {HTTP::Accept::MediaTypes::MediaRange.new("text", "plain", {})}
	
	it "should parse accept header" do
		media_types = HTTP::Accept::MediaTypes.browser_preferred_media_types('HTTP_ACCEPT' => text_plain_media_range.to_s)
		
		expect(media_types[0]).to be === text_plain_media_range
	end
end
