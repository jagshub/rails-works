# frozen_string_literal: true

module Products::Find
  extend self

  def by_url(url, exact: false)
    platform_url = PlatformStores.match_by_url(url)
    if platform_url
      normalized_url = platform_url.gsub(/^www\./, '').gsub(%r{/$}, '')
      return Product.find_by(clean_url: normalized_url)
    end

    uri = Addressable::URI.parse(url)
    return if uri.domain.blank?

    product = Product.find_by(clean_url: "#{ uri.host }#{ uri.path }")

    unless exact
      product ||= Product.find_by(clean_url: "#{ uri.domain }#{ uri.path }")
      product ||= Product.find_by(clean_url: uri.domain)

      if product.blank?
        # NOTE(Jagadeesh): clean_url is already lowercased, see UrlParser.clean_product_url so no need for LOWER here
        sanitized_domain = ActiveRecord::Base.sanitize_sql_like(uri.domain.to_s.downcase)
        product = Product.find_by('clean_url LIKE ?', "#{ sanitized_domain }%")
        product ||= Product.find_by('clean_url LIKE ?', "%.#{ sanitized_domain }%")
      end
    end

    product
  rescue Addressable::URI::InvalidURIError
    nil
  end

  def with_name_included_in(name)
    Product.where("? like '%' || LOWER(name) || '%'", name.downcase)
  end
end
