# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

require 'http/accept/media_types'
require 'http/accept/content_type'

describe HTTP::Accept::MediaTypes do
	let(:json_content_type) {HTTP::Accept::ContentType.new("application", "json")}
	let(:html_content_type) {HTTP::Accept::ContentType.new("text", "html")}
	let(:wildcard_media_range) {HTTP::Accept::MediaTypes::MediaRange.new("*", "*")}
	
	let(:map) {HTTP::Accept::MediaTypes::Map.new}
	
	# Sometimes it is necessary to handle very unusual configurations of Accept headers. This represents a specific case where requests which prioritise text/html or only match the wildcard should be handled independently of the case where application/json is specified. Because of how the map is configured, it is possible to specifically handle all three cases as required.
	it "should render json only if explicitly requested" do
		# Adding the wildcard first means that only '*/*' is specified, and won't be set by the json_content_type.
		map << wildcard_media_range << json_content_type << html_content_type
		
		expect(map.for(["*/*"])).to be == [wildcard_media_range, "*/*"]
		expect(map.for(["application/json"])).to be == [json_content_type, "application/json"]
		expect(map.for(["text/html"])).to be == [html_content_type, "text/html"]
	end
end
