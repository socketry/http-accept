# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.

require 'http/accept/content_type'

describe HTTP::Accept::ContentType do
	it "should raise argument error if constructed with wildcard" do
		expect{HTTP::Accept::ContentType.new("*", "*")}.to raise_exception(ArgumentError)
	end
end

describe HTTP::Accept::ContentType.new("text", "plain") do
	it "should format simple mime type" do
		expect(subject.to_s).to be == "text/plain"
	end
	
	it "can compare with string" do
		expect(subject).to be === "text/plain"
	end
	
	it "can compare with self" do
		expect(subject).to be === subject
	end
end

describe HTTP::Accept::ContentType.new("text", "plain", charset: 'utf-8') do
	it "should format simple mime type with options" do
		expect(subject.to_s).to be == "text/plain; charset=utf-8"
	end
end

describe HTTP::Accept::ContentType.new("text", "plain", charset: 'utf-8', q: 0.8) do
	it "should format simple mime type with multiple options" do
		expect(subject.to_s).to be == "text/plain; charset=utf-8; q=0.8"
	end
end

describe HTTP::Accept::ContentType.new("text", "plain", value: '["bar", "baz"]') do
	it "should format simple mime type with quoted options" do
		expect(subject.to_s).to be == "text/plain; value=\"[\\\"bar\\\", \\\"baz\\\"]\""
	end
	
	it "should round trip to the same quoted string" do
		media_types = HTTP::Accept::MediaTypes.parse(subject.to_s)
		
		expect(media_types[0].mime_type).to be == "text/plain"
		expect(media_types[0].parameters).to be == {'value' => '["bar", "baz"]'}
	end
end
