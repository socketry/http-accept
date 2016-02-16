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

require_relative 'quoted_string'

module HTTP
	module Accept
		class ContentType < Struct.new(:mime_type, :parameters)
			def initialize(mime_type, parameters = {})
				@to_s = nil
				
				super
			end
			
			def freeze
				@to_s ||= to_s
				
				super
			end
			
			def parameters_string
				return '' if parameters.empty?
				
				parameters.collect do |key, value|
					"; #{key.to_s}=#{QuotedString.quote(value.to_s)}"
				end.join
			end
			
			def === other
				if other.is_a? self.class
					super
				else
					return self.mime_type === other
				end
			end
			
			def to_s
				@to_s || "#{mime_type}#{parameters_string}"
			end
			
			alias to_str to_s
		end
	end
end
