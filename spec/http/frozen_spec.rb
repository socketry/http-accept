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
require 'http/accept/languages'

module HTTP::Accept::FrozenSpec
	RSpec.describe HTTP::Accept::MediaTypes::Map do
		Converter = Struct.new(:content_type) do
			def split(*args)
				self.content_type.split(*args)
			end
		end
		
		let(:text_html_converter) {Converter.new("text/html")}
		let(:text_plain_converter) {Converter.new("text/plain")}
		
		it "should be possible to query frozen state" do
			subject << text_html_converter
			subject << text_plain_converter
			
			subject.freeze
			
			media_types = HTTP::Accept::MediaTypes.parse("bob/dole, text/plain, text/*, */*")
			expect(subject.for(media_types).first).to be == text_plain_converter
		end
	end
	
	RSpec.describe HTTP::Accept::Languages::Locales do
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
end