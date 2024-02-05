# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
end

# Moved Development Dependencies
gem "covered"
gem "rspec", "~> 3.0"
