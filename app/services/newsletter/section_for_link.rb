# frozen_string_literal: true

module Newsletter::SectionForLink
  extend self

  def call(newsletter, url)
    url = clean_url(url)

    return if url.blank?
    return 'top_hunts' if top_hunt?(newsletter, url)
    return 'ad' if ad?(url)

    newsletter.sections.each do |section|
      section.content.to_s.scan(/href\s*=\s*"([^"]*)"/).flatten.push(section.url).uniq.each do |link|
        return section.tracking_label if clean_url(link) == url
      end
    end

    nil
  end

  private

  def top_hunt?(newsletter, url)
    newsletter.posts.each do |post|
      post_url = Routes.post_url(Post.find(post['id']).slug)
      post_url = Rails.env.production? ? post_url : to_https(post_url)
      return true if url == post_url
    end
    false
  end

  def ad?(url)
    url.starts_with?('https://www.producthunt.com/r/ad/')
  end

  def to_https(url)
    u = URI.parse(url)
    u.scheme = 'https'
    u.to_s
  end

  def clean_url(url)
    return if url.blank?
    return unless valid_url?(url)

    addressable_url = Addressable::URI.parse(url)
    return if addressable_url.site.blank?

    addressable_url.site + addressable_url.path
  end

  def valid_url?(url)
    return false if url.blank?

    uri = Addressable::URI.parse(url)
    uri.tld # will raise an error if it's invalid

    uri.scheme.in?(['http', 'https'])
  rescue Addressable::URI::InvalidURIError, PublicSuffix::DomainInvalid
    false
  end
end
