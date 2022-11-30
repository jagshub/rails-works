# frozen_string_literal: true

class Products::Scrapers::HTML::Base
  include Products::Scrapers::Utils::FieldSerializer

  attr_reader :doc, :response, :uri

  class << self
    def match(_uri)
      raise NotImplementedError
    end
  end

  def attribute_from_xpath(xpath, attribute)
    doc.xpath(xpath).first&.attribute(attribute)&.to_s
  end

  def attribute_from_selector(selector, attribute)
    doc.css(selector).first&.attribute(attribute)&.to_s
  end

  def images_from_selectors(selectors)
    selectors.map do |selector, attribute|
      format_image_source(attribute_from_selector(selector, attribute))
    end.compact
  end

  def links_from_selector(selector)
    doc.css(selector).map do |link|
      link.attribute('href')&.to_s
    end.compact_blank
  end

  def initialize(url)
    @uri = URI(url)
    @response = fetch_response
    return if @response.blank?

    @doc = Nokogiri::HTML(@response.body)
  end

  private

  HTTPARTY_OPTIONS = {
    follow_redirects: true,
    limit: 3,
    timeout: 30,
    headers: {
      'User-Agent' =>
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) '\
        'AppleWebKit/537.36 (KHTML, like Gecko) '\
        'Chrome/80.0.3987.149 Safari/537.36',
    },
  }.freeze
  def fetch_response
    HTTParty.get(uri, HTTPARTY_OPTIONS)
  rescue *ActiveJobHandleNetworkErrors::HTTP_ERRORS => e
    ErrorReporting.report_error_message(
      'Scraper unsuccessful',
      extra: { url: uri.to_s, error: e },
    )

    nil
  end

  def format_image_source(source)
    return if source.blank?
    return source if source.starts_with?('http')
    return uri.merge(source).to_s unless source.starts_with?('/')

    "#{ uri.scheme }://#{ uri.host }#{ source }"
  rescue URI::InvalidURIError, URI::BadURIError
    nil
  end
end
