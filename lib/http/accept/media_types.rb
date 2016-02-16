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
		module MediaTypes
			# According to https://tools.ietf.org/html/rfc7231#section-5.3.2
			MIME_TYPE = /(#{TOKEN})\/(#{TOKEN})/
			PARAMETER = /\s*;\s*(?<key>#{TOKEN})=((?<value>#{TOKEN})|(?<quoted_value>#{QUOTED_STRING}))/
			
			# Map a set of mime types to objects.
			class Map
				WILDCARD = "*/*".freeze
				
				def initialize
					@media_types = {}
				end
				
				def freeze
					unless frozen?
						@media_types.freeze
						@media_types.each{|key,value| value.freeze}
						
						super
					end
				end
				
				# Given a list of content types (e.g. from browser_preferred_content_types), return the best converter.
				def for(media_types)
					media_types.each do |media_range|
						mime_type = case media_range
							when String then media_range
							else media_range.mime_type
						end
						
						if object = @media_types[mime_type]
							return object, media_range
						end
					end
					
					return nil
				end
				
				# Add a converter to the collection. A converter can be anything that responds to #content_type.
				def << object
					type, subtype = object.content_type.split
					
					@media_types[WILDCARD] = object if @media_types.empty?
					@media_types["#{type}/*"] ||= object
					@media_types[object.content_type] = object
				end
			end
			
			class MediaRange < Struct.new(:mime_type, :parameters)
				def parameters_string
					return '' if parameters == nil or parameters.empty?
					
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
				
				def quality_factor
					parameters.fetch('q', 1.0).to_f
				end
				
				def split
					mime_type.split('/')
				end
				
				def self.parse(scanner, normalize_whitespace = true)
					return to_enum(:parse, scanner, normalize_whitespace) unless block_given?
					
					while mime_type = scanner.scan(MIME_TYPE)
						parameters = {}
						
						while scanner.scan(PARAMETER)
							key = scanner[:key]
							
							# If the regular expression PARAMETER matched, it must be one of these two:
							if value = scanner[:value]
								parameters[key] = value
							elsif quoted_value = scanner[:quoted_value]
								parameters[key] = QuotedString.unquote(quoted_value, normalize_whitespace)
							end
						end
						
						yield self.new(mime_type, parameters)
						
						# Are there more?
						break unless scanner.scan(/\s*,\s*/)
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

