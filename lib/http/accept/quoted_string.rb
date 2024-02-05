# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

module HTTP
	module Accept
		# According to https://tools.ietf.org/html/rfc7231#appendix-C
		TOKEN = /[!#$%&'*+\-.^_`|~0-9A-Z]+/i
		QUOTED_STRING = /"(?:.(?!(?<!\\)"))*.?"/
		
		module QuotedString
			# Unquote a "quoted-string" value according to https://tools.ietf.org/html/rfc7230#section-3.2.6
			# It should already match the QUOTED_STRING pattern above by the parser.
			def self.unquote(value, normalize_whitespace = true)
				value = value[1...-1]
				
				value.gsub!(/\\(.)/, '\1') 
				
				if normalize_whitespace
					# LWS = [CRLF] 1*( SP | HT )
					value.gsub!(/[\r\n]+\s+/, ' ')
				end
				
				return value
			end
			
			# Quote a string if required. Doesn't handle newlines correctly currently.
			def self.quote(value, force = false)
				if value =~ /"/ or force
					"\"#{value.gsub(/["\\]/, "\\\\\\0")}\""
				else
					return value
				end
			end
		end
	end
end
