# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.
# Copyright, 2016, by Matthew Kerwin.
# Copyright, 2017, by Andy Brody.

require_relative 'accept/version'

# Accept: header
require_relative 'accept/media_types'
require_relative 'accept/content_type'

# Accept-Encoding: header
require_relative 'accept/encodings'

# Accept-Language: header
require_relative 'accept/languages'

module HTTP
	module Accept
	end
end
