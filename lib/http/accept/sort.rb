# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

module HTTP
	module Accept
		module Sort
			# This sorts items with higher priority first, and keeps items with the same priority in the same relative order.
			def self.by_quality_factor(items)
				# We do this to get a stable sort:
				items.sort_by.with_index{|object, index| [-object.quality_factor, index]}
			end
		end
	end
end
