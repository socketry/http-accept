# HTTP::Accept

Provides a robust set of parsers for dealing with Accept and Accept-Language HTTP headers.

Current `Accept-Encoding:` and `Accept-Charset:` are not supported. This is because they are not particularly useful headers, but PRs are welcome.

## Installation

Add this line to your application's Gemfile:

	gem 'http-accept'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install http-accept

## Usage

Here are some examples of how to parse various headers.

### Parsing Accept: headers

	media_types = HTTP::Accept::MediaTypes.parse("text/html;q=0.5, application/json; version=1")

	expect(media_types[0].mime_type).to be == "application/json"
	expect(media_types[0].parameters).to be == {'version' => '1'}
	expect(media_types[1].mime_type).to be == "text/html"
	expect(media_types[1].parameters).to be == {'q' => '0.5'}

### Parsing Accept-Language: headers

	languages = HTTP::Accept::Language.parse("da, en-gb;q=0.8, en;q=0.7")

	expect(languages[0].locale).to be == "da"
	expect(languages[1].locale).to be == "en-gb"
	expect(languages[2].locale).to be == "en"`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2016, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
