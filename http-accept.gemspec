# frozen_string_literal: true

require_relative "lib/http/accept/version"

Gem::Specification.new do |spec|
	spec.name = "http-accept"
	spec.version = HTTP::Accept::VERSION
	
	spec.summary = "Parse Accept and Accept-Language HTTP headers."
	spec.authors = ["Samuel Williams", "Alexis Bernard", "Matthew Kerwin", "Alif Rachmawadi", "Andy Brody", "Ian Oxley", "Khaled Hassan Hussein", "Olle Jonsson", "Robert Pritzkow"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/ioquatix/http-accept"
	
	spec.metadata = {
		"bug_tracker_uri" => "https://github.com/ioquatix/http-accept/issues",
		"changelog_uri" => "https://github.com/ioquatix/http-accept/blob/main/releases.md",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/ioquatix/http-accept.git",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.3"
end
