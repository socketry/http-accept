# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

require 'http/accept/media_types'
require 'http/accept/languages'

describe HTTP::Accept::MediaTypes::Map do
	let(:converter) do
		Struct.new(:content_type) do
			def split(*args)
				self.content_type.split(*args)
			end
		end
	end
	
	let(:text_html_converter) {converter.new("text/html")}
	let(:text_plain_converter) {converter.new("text/plain")}
	
	let(:map) {subject.new}
	
	it "should be possible to query frozen state" do
		map << text_html_converter
		map << text_plain_converter
		
		map.freeze
		
		media_types = HTTP::Accept::MediaTypes.parse("bob/dole, text/plain, text/*, */*")
		expect(map.for(media_types).first).to be == text_plain_converter
	end
end

describe HTTP::Accept::Languages::Locales do
	# Specified by the server, content localizations that are actually available:
	let(:locales) {HTTP::Accept::Languages::Locales.new(["en-us", "en-nz", "en-au"])}
	
	it "should be possible to query frozen state" do
		locales.freeze
		
		# Provided by the client:
		languages = HTTP::Accept::Languages.parse("ja, en-au, en")
		
		# The localized content which is best for this user:
		expect(locales & languages).to be == ["en-au", "en-us"]
	end
end
