# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016, by Matthew Kerwin.
# Copyright, 2017-2024, by Samuel Williams.

require 'strscan'

require_relative 'parse_error'
require_relative 'quoted_string'
require_relative 'sort'

module HTTP
	module Accept
		module Encodings
			# https://tools.ietf.org/html/rfc7231#section-5.3.4
			CONTENT_CODING = TOKEN
			
			# https://tools.ietf.org/html/rfc7231#section-5.3.1
			QVALUE = /0(\.[0-9]{0,3})?|1(\.[0]{0,3})?/
			
			CODINGS = /(?<encoding>#{CONTENT_CODING})(;q=(?<q>#{QVALUE}))?/
			
			ContentCoding = Struct.new(:encoding, :q) do
				def quality_factor
					(q || 1.0).to_f
				end
				
				def self.parse(scanner)
					return to_enum(:parse, scanner) unless block_given?
					
					while scanner.scan(CODINGS)
						yield self.new(scanner[:encoding], scanner[:q])
						
						# Are there more?
						break unless scanner.scan(/\s*,\s*/)
					end
					
					raise ParseError.new('Could not parse entire string!') unless scanner.eos?
				end
			end
			
			def self.parse(text)
				scanner = StringScanner.new(text)
				
				encodings = ContentCoding.parse(scanner)
				
				return Sort.by_quality_factor(encodings)
			end
			
			HTTP_ACCEPT_ENCODING = 'HTTP_ACCEPT_ENCODING'.freeze
			WILDCARD_CONTENT_CODING = ContentCoding.new('*', nil).freeze
			IDENTITY_CONTENT_CODING = ContentCoding.new('identity', nil).freeze
			
			# Parse the list of browser preferred content codings and return ordered by priority. If no
			# `Accept-Encoding:` header is specified, the behaviour is the same as if
			# `Accept-Encoding: *` was provided, and if a blank `Accept-Encoding:` header value is
			# specified, the behaviour is the same as if `Accept-Encoding: identity` was provided
			# (according to RFC).
			def self.browser_preferred_content_codings(env)
				if accept_content_codings = env[HTTP_ACCEPT_ENCODING]&.strip
					if accept_content_codings.empty?
						# "An Accept-Encoding header field with a combined field-value that is
						# empty implies that the user agent does not want any content-coding in
						# response."
						return [IDENTITY_CONTENT_CODING]
					else
						return HTTP::Accept::Encodings.parse(accept_content_codings)
					end
				end
				
				# "If no Accept-Encoding field is in the request, any content-coding
				#  is considered acceptable by the user agent."
				return [WILDCARD_CONTENT_CODING]
			end
		end
	end
end
