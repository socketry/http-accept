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

RSpec.shared_examples "wildcard media range" do |env|
	let(:wildcard_media_ranges) {[HTTP::Accept::MediaTypes::WILDCARD_MEDIA_RANGE]}
	
	it "should match any content type" do
		expect(HTTP::Accept::MediaTypes.browser_preferred_media_types(env)).to be == wildcard_media_ranges
	end
end

RSpec.describe HTTP::Accept::MediaTypes do
	include_examples "wildcard media range", {'HTTP_ACCEPT' => '   */*   '}
	include_examples "wildcard media range", {'HTTP_ACCEPT' => '*/*'}
	
	# http://stackoverflow.com/questions/12130910/how-to-interpret-empty-http-accept-header
	include_examples "wildcard media range", {'HTTP_ACCEPT' => '   '}
	include_examples "wildcard media range", {'HTTP_ACCEPT' => ''}
	
	let(:text_plain_media_range) {HTTP::Accept::MediaTypes::MediaRange.new("text/plain", {})}
	
	it "should parse accept header" do
		media_types = HTTP::Accept::MediaTypes.browser_preferred_media_types('HTTP_ACCEPT' => text_plain_media_range.to_s)
		
		expect(media_types[0]).to be === text_plain_media_range
	end
end
