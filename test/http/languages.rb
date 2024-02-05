# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016-2024, by Samuel Williams.
# Copyright, 2021, by Khaled Hassan Hussein.

require 'http/accept/languages'

describe HTTP::Accept::Languages do
	it "should parse basic header" do
		languages = HTTP::Accept::Languages.parse("da, en-gb;q=0.5, en;q=0.25")
		
		expect(languages[0].locale).to be == "da"
		expect(languages[0].quality_factor).to be == 1.0
		
		expect(languages[1].locale).to be == "en-gb"
		expect(languages[1].quality_factor).to be == 0.5
		
		expect(languages[2].locale).to be == "en"
		expect(languages[2].quality_factor).to be == 0.25
	end
	
	it "should order based on quality factor" do
		languages = HTTP::Accept::Languages.parse("en-gb;q=0.25, en;q=0.5, en-us")
		expect(languages.collect(&:locale)).to be == %w{en-us en en-gb}
		
		languages = HTTP::Accept::Languages.parse("en-us,en-gb;q=0.8,en;q=0.6,es-419")
		expect(languages.collect(&:locale)).to be == %w{en-us es-419 en-gb en}
	end
	
	it "should accept wildcard language" do
		languages = HTTP::Accept::Languages.parse("*;q=0")
		
		expect(languages[0].locale).to be == "*"
		expect(languages[0].quality_factor).to be == 0
	end
	
	it "should preserve relative order" do
		languages = HTTP::Accept::Languages.parse("en, de;q=0.5, jp;q=0.5")
		
		expect(languages[0].locale).to be == "en"
		expect(languages[1].locale).to be == "de"
		expect(languages[2].locale).to be == "jp"
	end
	
	it "should parse with optional whitespace" do
		languages = HTTP::Accept::Languages.parse("de, en-US; q=0.7, en ; q=0.3")
		
		expect(languages[0].locale).to be == "de"
		expect(languages[1].locale).to be == "en-US"
		expect(languages[2].locale).to be == "en"
	end

	it "should accept quality factors up to 6 decimal places" do
		languages = HTTP::Accept::Languages.parse("en;q=0.123456")

		expect(languages[0].locale).to be == "en"
		expect(languages[0].quality_factor).to be == 0.123456
	end

	it "should not accept quality factors with more than 6 decimal places" do
		text = "en;q=0.1234567"

		expect{HTTP::Accept::Languages.parse(text)}.to raise_exception(HTTP::Accept::ParseError)
	end
	
	it "should not accept invalid input" do
		[
			"en;f=1", "de;jp",
			";", ","
		].each do |text|
			expect{HTTP::Accept::Languages.parse(text)}.to raise_exception(HTTP::Accept::ParseError)
		end
	end
end

describe HTTP::Accept::Languages::Locales do
	# Specified by the server, content localizations that are actually available:
	let(:locales) {HTTP::Accept::Languages::Locales.new(["en-us", "en-nz", "en-au"])}
	
	it "should filter and expand the requested locales" do
		# Provided by the client:
		languages = HTTP::Accept::Languages.parse("en-au, en")
		
		# The localized content which is best for this user:
		expect(locales & languages).to be == ["en-au", "en-us"]
	end
	
	it "it should filter the requested locale" do
		languages = HTTP::Accept::Languages.parse("en-au")
		expect(locales & languages).to be == ["en-au"]
	end
	
	it "it should expand the requested locale" do
		languages = HTTP::Accept::Languages.parse("en")
		expect(locales & languages).to be == ["en-us"]
	end
	
	it "should include all generic locales" do
		expect(locales).to be(:include?, "en-us")
		expect(locales).to be(:include?, "en-nz")
		expect(locales).to be(:include?, "en-au")
		expect(locales).to be(:include?, "en")
	end
	
	it "can be joined into a string" do
		expect(locales.join(',')).to be == "en-us,en-nz,en-au"
	end
	
	it "can be added together" do
		others = ['ja']
		all_locales = locales + others
		
		expect(all_locales).to be(:include?, "en-us")
		expect(all_locales).to be(:include?, "en-nz")
		expect(all_locales).to be(:include?, "en-au")
		expect(all_locales).to be(:include?, "en")
		expect(all_locales).to be(:include?, "ja")
	end
	
	it "can be converted to an array of names" do
		expect(locales.to_a).to be == locales.names
	end
	
	it "can be enumerated using each" do
		expect(locales.each.to_a).to be == locales.names
	end
end
