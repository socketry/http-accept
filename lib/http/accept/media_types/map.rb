# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

module HTTP
	module Accept
		module MediaTypes
			# Map a set of mime types to objects. Media types are matched case-insensitively according to https://www.rfc-editor.org/rfc/rfc9110#section-8.3.1
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
						if object = @media_types[key_for(media_range)]
							return object, media_range
						end
					end
					
					return nil
				end
				
				def []= media_range, object
					@media_types[key_for(media_range)] = object
				end
				
				def [] media_range
					@media_types[key_for(media_range)]
				end
				
				# Add a converter to the collection. A converter can be anything that responds to #content_type. Objects will be considered in the order they are added, subsequent objects cannot override previously defined media types. `object` must respond to #split('/', 2) which should give the type and subtype.
				def << object
					type, subtype = object.split("/", 2).map(&:downcase)
					
					# We set the default if not specified already:
					@media_types[WILDCARD] = object if @media_types.empty?
					
					if type != "*"
						@media_types["#{type}/*"] ||= object
						
						if subtype != "*"
							@media_types["#{type}/#{subtype}"] ||= object
						end
					end
					
					return self
				end
				
				private
				
				# Media types are case-insensitive, so media ranges are keyed by their lower-case mime type. Other keys are used as given.
				def key_for(media_range)
					media_range = media_range.mime_type if media_range.respond_to?(:mime_type)
					
					if media_range.respond_to?(:to_str)
						media_range.to_str.downcase
					else
						media_range
					end
				end
			end
		end
	end
end

