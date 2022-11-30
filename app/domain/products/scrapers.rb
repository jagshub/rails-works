# frozen_string_literal: true

module Products::Scrapers
  extend self

  # NOTE(DZ): This is a list of scrapers. If your scraper should be considered
  # when build_from_url/1 is called, add it to this list
  # before Products::Scrapers::HTML::Meta.
  SCRAPERS = [
    Products::Scrapers::HTML::Meta,
  ].freeze

  def html(product:, url:, scraper: nil)
    scraper_klass = scraper || find_scraper(url)
    return if scraper_klass.blank?

    scraper_obj = scraper_klass.new(url)
    data = scraper_obj.to_h
    return if data.blank?

    save_scrape_result(product, scraper_klass, data, url: url)
    scraper_obj
  end

  JSON_SCRAPERS = [
    Products::Scrapers::JSON::Clearbit,
    Products::Scrapers::JSON::Webshrinker,
  ].freeze

  def json(product:, scraper: nil)
    scrapers = scraper.present? ? Array(scraper) : JSON_SCRAPERS

    scrapers.map do |scraper_klass|
      scraper_obj = scraper_klass.new(product)
      data = scraper_obj.to_h
      save_scrape_result(product, scraper_klass, data) if data.present?
      scraper_obj
    end
  end

  def schedule(product:, cache: true)
    url = product.website_url
    # NOTE(DZ): Currently we don't replay the results
    unless cache && Products::ScrapeResult.by_product_url(product, url).any?
      Products::Scrapers::Jobs::HTML.perform_async(
        product_id: product.id,
        url: url,
      )
    end

    # NOTE(DZ): Running the same JSON scraper twice will cause errors
    Products::Scrapers::Jobs::JSON.perform_async(product_id: product.id)
  end

  private

  # TODO(DZ): When a scraper gets updated, it'll break jsonb structure of
  # Products::ScraperResult. Need a version control mechanic here and in db
  def save_scrape_result(product, scraper_klass, data, url: nil)
    product_form = Products::Form.new(product, source_klass: scraper_klass)

    ActiveRecord::Base.transaction do
      Products::ScrapeResult.create!(
        product: product,
        url: url,
        data: data,
        source: scraper_klass,
      )

      Audited.audit_class.as_user("System Scraper: #{ scraper_klass }") do
        product_form.update!(data)
      end
    end
  end

  def find_scraper(url)
    return if url.blank?
    return unless UrlParser.url_valid?(url)

    uri = URI(url)
    SCRAPERS.find { |klass| klass.match(uri) }
  end
end
