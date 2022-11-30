# Product Scrapers

Write web scrapers for products. Inspiration from [everypolitician/scraped](https://github.com/everypolitician/scraped)

## How-To

### Define a html scraper

```ruby
  module Products::Scrapers::HTML
    class GooglePlayStore < Base
      # match/1
      # Specify urls this scraper is valid for with block/1. Argument to block
      # is an URI object. Matching condition should be unique to your string
      # and nothing else
      #
      def self.match(uri)
        url.host =~ /play.google.com/
      end

      # field/2
      # Specify fields via key, block pair. The available set of attributes you
      # can scrape is defined in `Product::SCRAPABLE_FIELDS`. You can also see
      # the list via console by:
      #
      #   Products::Scrapers::HTML::GooglePlayStore.attributes
      #
      # This will create a key-value pair in the scraper hash result. It'll also
      # create an accessor for method like access
      #
      #   object.to_h => { tagline: ...value from this block }
      #
      #   or
      #
      #   object.tagline => ...value from this block
      #
      field :tagline do
        # Parse html doc
        # Check out some helpers in Products::Scrapers::HTML::Base
      end
    end
  end
```

### Define a JSON scraper

```ruby
  module Products::Scrapers::JSON
    class Clearbit < Base
      # invoke/1
      # Call your API in this method. It is a good idea to cache the results of
      # this call via External::APIResponse.fetch/2. Todo so, apply your API
      # method call in the 2nd param block of External::APIResponse.fetch/2
      #
      # Return of this method should be the **Hash** response of the API, which
      # will then be passed to your field methods
      #
      invoke do |product|
        api_response = External::APIResponse.fetch(
          params: { website_url: product.website_url },
          kind: :clearbit_company,
        ) do
          External::ClearbitAPI.find(domain: product.website_url)
        end

        api_response.response
      end

      # field/2
      # Same as HTML Scrapers. The `response` attribute will be available from
      # the return of your invoke/1
      field :description do
        response['description']
      end
    end
  end
```

### Add it to the sorted list

If your scraper should be one of the possible choices when `Products::Scrapers.html/2` gets called (without the `scraper:` parameter), then add it accordingly. **List order is used to determin priority**.

For JSON scrapers, all scrapers will be ran with each call of `Products::Scrapers.json/1` so order does not matter.

```ruby
  module Products::Scrapers
    ...

    SCRAPERS = [
      # Add your scraper here
      Products::Scrapers::HTML::GooglePlayStore,

      # Catch all, nothing below Products::Scrapers::HTML::Meta
      Products::Scrapers::HTML::Meta,
    ].freeze
    ...

    JSON_SCRAPERS = [
      Products::Scrapers::JSON::Clearbit,
    ].freeze

    ...
  end
```

### Run it

Running scraper asynchronously

```ruby
  # This will schedule the suite of scrapers we have available. Good for
  # applicaton based client requests. specify cache: false for ignore previously
  # scraped results.
  Products::Scrapers.schedule(product: product, cache: false)
```

Running scraper synchronously

```ruby
  # Build scraper object
  scraper = Products::Scrapers::HTML::GooglePlayStore.new(url)

  # Resulting attributes from parse
  attrs = scraper.to_h

  # Or access data via accessors
  tagline = scraper.tagline
```

`Products::Scrapers.html/2` looks at all scraper classes in the `Products::Scrapers::SCRAPERS` constant. It will use the first class that passes `match/1` (defined in your scraper).

```ruby
  # This will match and run Products::Scrapers::HTML::GooglePlayStore only
  Products::Scrapers.html(
    product: product,
    url: 'https://play.google.com/store/apps/details?id=com.albiononline&hl=en_CA&gl=US',
  )
```

### Test it

There is a `shared_example` helper for writing scraper specs. Check out [meta_spec](spec/domain/products/scrapers/html/meta_spec.rb)

```ruby
  require 'domain/products/scrapers/html/shared_examples'

  describe Products::Scrapers::HTML::GooglePlayStore do
    example_page = <<-HTML
      <html>
        <head>
          <title>This is a title</title>
        </head>
      </html>
    HTML

    it_behaves_like 'a product scraper', example_page, tagline: 'This is a title'
    it_behaves_like 'a product scraper', '', tagline: nil
  end
```

For JSON scrapers, you will need to stub your API call yourself.

```ruby
  require 'domain/products/scrapers/json/shared_examples'

  describe Products::Scrapers::JSON::Clearbit do
    before do
      allow(External::ClearbitAPI).to(
        receive(:company).and_return(SpecSupport::External::Clearbit::RESPONSE),
      )
    end

    it_behaves_like(
      'a JSON product scraper',
      description: 'Slack Technologies, Inc. is an American international '\
        'software company founded in 2009 in Vancouver, British Columbia.',
    )
  end
```

## Under the hood

File structure

```
  domains/
  |-products/
  | |-scrapers/
  | | |-html/               # All HTML parsers
  | | | |-base.rb           # Base HTML class, inherit this
  | | | |-your_scraper.rb   # Add new HTML scrapers here
  | | |-json/
  | | | |-base.rb           # Base JSON class, inherit this
  | | | |-your_scraper.rb   # Add new JSON scrapers here
  | | |-jobs/               # Jobs for asynchronous scraping
  | | |-utils/              # Helper modules for scrapers
  |-scrapers.rb             # Top level driver methods (html/2, json/1)
```
