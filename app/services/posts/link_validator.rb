# frozen_string_literal: true

module Posts::LinkValidator
  extend self

  def call(url)
    return :invalid unless valid_url? url

    post = Posts::Duplicates.find_all(url: url).first

    return [:duplicate, post] if post

    :valid
  end

  private

  def valid_url?(url)
    return false if url.blank?

    uri = Addressable::URI.parse(url)
    uri.tld # will raise an error if it's invalid

    uri.scheme.in?(['http', 'https'])
  rescue Addressable::URI::InvalidURIError, PublicSuffix::DomainInvalid
    false
  end
end
