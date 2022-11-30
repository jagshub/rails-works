# frozen_string_literal: true

module LinkSpect
  extend self

  def check_spam_comment(comment)
    return if comment.blank?

    links = Nokogiri::HTML(comment.body).search('a/@href').map(&:value)
    return if links.empty?

    check_spam(urls: links)
  end

  def check_spam(urls:)
    now = Time.zone.now

    urls = clean_url urls.compact
    return if urls.empty?

    logs = existing_logs(urls, now)
    return 'Link(s) already blocked' if ::LinkSpect::Response.blocked?(logs)

    # Note(Rahul): Keep LinkSpect::Awis in the end since it logs all the checked safe urls which other filters doesn't do.
    # Other filters will log only blocked responses.
    check_urls = urls - logs.map(&:external_link)
    return 'Link(s) failed google safe browsing check' if ::LinkSpect::SafeBrowsing.blocked?(check_urls)
    return 'Link(s) failed awis spam check' if ::LinkSpect::Awis.blocked?(check_urls)
  end

  def valid?(url:)
    raise ArgumentError, 'url is missing' if url.blank?

    !!(url =~ /\A#{ URI.regexp(['http', 'https']) }\z/)
  end

  private

  def existing_logs(urls, now)
    LinkSpect::Log.active(now).where(external_link: urls)
  end

  def clean_url(urls)
    urls.map do |url|
      next if url.blank?

      url = Addressable::URI.unescape(url)
      next unless valid?(url: url)

      host = Addressable::URI.parse(url).host&.downcase
      next if !host || host.split('www.').last == 'producthunt.com'

      Addressable::URI.escape(url)
    end.compact
  end
end
