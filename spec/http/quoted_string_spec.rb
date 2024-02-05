# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2019, by Samuel Williams.

require 'http/accept/quoted_string'

RSpec.describe HTTP::Accept::MediaTypes do
	it "should ignore linear whitespace" do
		quoted_string = HTTP::Accept::QuotedString.unquote(%Q{"Hello\r\n  World"})
		
		expect(quoted_string).to be == "Hello World"
	end
end
