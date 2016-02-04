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
				WILDCARD = '*'.freeze
				
				def initialize
					@media_types = Hash.new{|h,k| h[k] = {}}
					
					# Primarily for implementing #freeze efficiently.
					@all = []
				end
				
				def freeze
					@media_types.freeze
					@media_types.each{|key,value| value.freeze}
					
					@all.freeze
					@all.each(&:freeze)
					
					super
				end
				
				# Given a list of content types (e.g. from browser_preferred_content_types), return the best converter.
				def for(media_types)
					media_types.each do |media_range|
						type, subtype = media_range.split
						
						if object = @media_types[type][subtype]
							return object, media_range
						end
					end
					
					return nil
				end
				
				# Add a converter to the collection. A converter can be anything that responds to #content_type.
				def << object
					type, subtype = object.content_type.split('/')
					
					if @media_types.empty?
						@media_types[WILDCARD][WILDCARD] = object
					end
					
					if @media_types[type].empty?
						@media_types[type][WILDCARD] = object
					end
					
					@media_types[type][subtype] = object
					@all << object
				end
			end
			
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

