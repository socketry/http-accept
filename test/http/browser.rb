# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2019, by Samuel Williams.

require 'http/accept/media_types'
require 'http/accept/content_type'

ServerContextTypes = Sus::Shared("server content types") do
	let(:json_content_type) {HTTP::Accept::ContentType.new("application", "json")}
	let(:html_content_type) {HTTP::Accept::ContentType.new("text", "html")}
	let(:wildcard_media_range) {HTTP::Accept::MediaTypes::MediaRange.new("*", "*")}
	
	let(:map) {HTTP::Accept::MediaTypes::Map.new}
	let(:media_types) {HTTP::Accept::MediaTypes.parse(accept_header)}
end

AWebBrowser = Sus::Shared("a web browser") do
	include_context ServerContextTypes
	
	it "should match text/html" do
		map << html_content_type
		map << json_content_type
		
		object, _ = map.for(media_types)
		
		expect(object).to be == html_content_type
	end
end

describe "Firefox Accept: headers" do
	let(:accept_header) {"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"}
	it_behaves_like AWebBrowser
end

describe "WebKit Accept: headers" do
	let(:accept_header) {"application/xml,application/xhtml+xml,text/html;q=0.9, text/plain;q=0.8,image/png,*/*;q=0.5"}
	it_behaves_like AWebBrowser
end

describe "Safari 5 Accept: headers" do
	let(:accept_header) {"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"}
	it_behaves_like AWebBrowser
end

describe "Internet Explorer 8 Accept: headers" do
	# http://stackoverflow.com/questions/1670329/ie-accept-headers-changing-why
	let(:accept_header) {"image/jpeg, application/x-ms-application, image/gif, application/xaml+xml, image/pjpeg, application/x-ms-xbap, application/x-shockwave-flash, application/msword, */*"}
	it_behaves_like AWebBrowser
end

describe "Opera Accept: headers" do
	let(:accept_header) {"text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/webp, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1"}
	it_behaves_like AWebBrowser
end

describe "XMLHttpRequest Accept: headers" do
	let(:accept_header) {"application/json"}
	
	include_context ServerContextTypes
	
	it "should match application/json" do
		map << json_content_type
		
		object, _ = map.for(media_types)
		
		expect(object).to be == json_content_type
	end
end
