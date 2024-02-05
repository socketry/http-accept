# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

require_relative 'media_types'
require_relative 'quoted_string'

module HTTP
	module Accept
		# A content type is different from a media range, in that a content type should not have any wild cards.
		class ContentType < MediaTypes::MediaRange
			def initialize(type, subtype, parameters = {})
				# We do some basic validation here:
				raise ArgumentError.new("#{self.class} can not have wildcards: #{type}", "#{subtype}") if type.include?('*') || subtype.include?('*')
				
				super
			end
		end
	end
end
