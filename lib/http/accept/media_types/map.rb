# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

module HTTP
	module Accept
		module MediaTypes
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
				
				# Given a list of content types (e.g. from browser_preferred_content_types), return the best converter. Media types can be an array of MediaRange or String values.
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
				
				def []= media_range, object
					@media_types[media_range] = object
				end
				
				def [] media_range
					@media_types[media_range]
				end
				
				# Add a converter to the collection. A converter can be anything that responds to #content_type. Objects will be considered in the order they are added, subsequent objects cannot override previously defined media types. `object` must respond to #split('/', 2) which should give the type and subtype.
				def << object
					type, subtype = object.split('/', 2)
					
					# We set the default if not specified already:
					@media_types[WILDCARD] = object if @media_types.empty?
					
					if type != '*'
						@media_types["#{type}/*"] ||= object
						
						if subtype != '*'
							@media_types["#{type}/#{subtype}"] ||= object
						end
					end
					
					return self
				end
			end
		end
	end
end

