# frozen_string_literal: true

module LinkSpect::SafeBrowsing
  extend self

  GOOGLE_API_URL = 'https://safebrowsing.googleapis.com/v4/threatMatches:find'

  def blocked?(urls)
    key = ENV['SAFE_BROWSING_KEY']
    raise StandardError, 'API Key not found' if key.blank?

    resp = HTTParty.post(
      "#{ GOOGLE_API_URL }?key=#{ key }",
      body: safe_browser_body(urls),
      headers: { 'Content-Type' => 'application/json' },
    )

    obj = JSON.parse(resp.response.body) || {}
    now = Time.zone.now
    safe = obj.empty? || (obj['matches'] || []).empty?

    return false if safe

    url_data = safe_browse_parse(obj['matches'])

    result = urls.map do |url|
      cache_time = url_data[url]

      ::LinkSpect::Response::Log.new(
        external_link: url,
        blocked: cache_time.present?,
        source: 'safe_browsing',
        expires_at: now + cache_time.max.seconds,
      )
    end

    ::LinkSpect::Response.blocked? result, 'safe_browsing'
  end

  private

  def safe_browse_parse(matches)
    url_data = {}

    matches.each do |match|
      value = url_data[match['threat']['url']] || []
      value.append(match['cacheDuration'].split('s').first&.to_i || 0)

      url_data[match['threat']['url']] = value
    end

    url_data
  end

  def safe_browser_body(urls)
    {
      client: {
        clientId: Rails.env.production? ? 'producthunt' : 'producthuntdev',
        clientVersion: '1.5.2',
      },
      threatInfo: {
        threatTypes: ['MALWARE', 'SOCIAL_ENGINEERING', 'UNWANTED_SOFTWARE'],

        platformTypes: ['ANY_PLATFORM'],
        threatEntryTypes: ['URL'],
        threatEntries: urls.map { |url| { 'url' => url } },
      },
    }.to_json
  end
end
