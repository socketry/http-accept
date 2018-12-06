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
require 'http/accept/content_type'

RSpec.describe HTTP::Accept::MediaTypes do
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
