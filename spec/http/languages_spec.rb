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

require 'http/accept/languages'

module HTTP::Accept::LanguagesSpec
	describe HTTP::Accept::Languages do
		it "should parse basic header" do
			languages = HTTP::Accept::Languages.parse("da, en-gb;q=0.5, en;q=0.25")
			
			expect(languages[0].locale).to be == "da"
			expect(languages[0].quality_factor).to be == 1.0
			
			expect(languages[1].locale).to be == "en-gb"
			expect(languages[1].quality_factor).to be == 0.5
			
			expect(languages[2].locale).to be == "en"
			expect(languages[2].quality_factor).to be == 0.25
		end
		
		it "should order based on quality factor" do
			languages = HTTP::Accept::Languages.parse("en-gb;q=0.25, en;q=0.5, en-us")
			
			expect(languages[0].locale).to be == "en-us"
			expect(languages[1].locale).to be == "en"
			expect(languages[2].locale).to be == "en-gb"
		end
		
		it "should accept wildcard language" do
			languages = HTTP::Accept::Languages.parse("*;q=0")
			
			expect(languages[0].locale).to be == "*"
			expect(languages[0].quality_factor).to be == 0
		end
	end
end