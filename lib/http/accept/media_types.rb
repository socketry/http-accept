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

require 'strscan'

require_relative 'parse_error'
require_relative 'quoted_string'
require_relative 'sort'

module HTTP
	module Accept
		class MediaTypes
			# According to https://tools.ietf.org/html/rfc7231#section-5.3.2
			MIME_TYPE = /(#{TOKEN})\/(#{TOKEN})/
			PARAMETER = /\s*;\s*(?<key>#{TOKEN})=((?<value>#{TOKEN})|(?<quoted_value>#{QUOTED_STRING}))/
			
			class MediaRange < Struct.new(:mime_type, :parameters)
				def quality_factor
					parameters.fetch('q', 1.0).to_f
				end
				
				def split
					@type, @subtype = mime_type.split('/')
				end
				
				def self.parse(scanner, normalize_whitespace = true)
					return to_enum(:parse, scanner, normalize_whitespace) unless block_given?
					
					while mime_type = scanner.scan(MIME_TYPE)
						parameters = {}
						
						while scanner.scan(PARAMETER)
							key = scanner[:key]
							
							if value = scanner[:value]
								parameters[key] = value
							elsif quoted_value = scanner[:quoted_value]
								parameters[key] = QuotedString.unquote(quoted_value, normalize_whitespace)
							else
								raise ParseError.new("Could not parse parameter!")
							end
						end
						
						yield self.new(mime_type, parameters)
						
						# Are there more?
						return unless scanner.scan(/\s*,\s*/)
					end
					
					raise ParseError.new("Could not parse entire string!") unless scanner.eos?
				end
			end
			
			def self.parse(text, normalize_whitespace = true)
				scanner = StringScanner.new(text)
				
				media_types = MediaRange.parse(scanner, normalize_whitespace)
				
				return Sort.by_quality_factor(media_types)
			end
		end
	end
end

