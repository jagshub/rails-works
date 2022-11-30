# frozen_string_literal: true

# Documentation
#
# - service: https://serpapi.com/
# - api: https://serpapi.com/dashboard
# - manage: https://serpapi.com/manage-api-key

module External::SerpApi
  extend self

  def find_product_for_scraper(product_name:)
    return if product_name.blank? || product_name.to_s.strip.length < 3

    # NOTE(Raj): we aren't appending string like '#{name} product website',
    #            because we don't want to miss google's knowledge graph data.
    search_results = api_call(product_name)
    return if search_results.blank?

    organic_search_results = search_results['organic_results'] || []
    return if organic_search_results.blank?

    # NOTE(Raj): we assume the first organic result(no ads and not from blacklisted domains) as the product website.
    first_result = organic_search_results&.find { |result| allow_result?(result) }
    return if first_result.blank?

    {
      title: first_result['title'],
      website_url: first_result['link'],
      description: first_result.dig('about_this_result', 'source', 'description'),
      logo: first_result.dig('about_this_result', 'source', 'icon'),
      **social_urls(search_results.dig('knowledge_graph', 'profiles') || []),
    }
  end

  private

  def social_urls(profiles)
    urls = {}

    profiles.each do |profile|
      urls[:twitter_url] = profile['link'] if profile['name'] == 'Twitter'
      urls[:facebook_url] = profile['link'] if profile['name'] == 'Facebook'
      urls[:instagram_url] = profile['link'] if profile['name'] == 'Instagram'
    end

    urls
  end

  BASE_QUERY_PARAMS = {
    engine: 'google',
    google_domain: 'google.com',
    gl: 'us',
    hl: 'en',
    location: 'austin, texas, united states',
    api_key: Config.serpapi_key,
    no_cache: 'true',
    safe: 'active',
  }.freeze

  def api_call(query)
    query_params = BASE_QUERY_PARAMS.merge(q: CGI.escape(query))

    serp_api_url = URI::HTTPS.build(host: 'serpapi.com', path: '/search.json', query: query_params.to_query).to_s

    HandleNetworkErrors.call(fallback: nil) do
      response = HTTParty.get(serp_api_url, format: :json)
      response.parsed_response.to_h
    end
  end

  BLACKLISTED_DOMAINS = %w(
    9to5mac
    aliexpress
    androidpolice
    arstechnica
    bbc
    bestbuy
    bhphotovideo
    bloomberg
    buzzfeed
    capterra
    cnbc
    cnet
    consumerreports
    digitaltrends
    ebay
    edmunds
    engadget
    engadget
    facebook
    forbes
    forbes
    fortune
    ft
    g2
    gamespot
    gamestop
    glassdoor
    goodguide
    goodhousekeeping
    ign
    imdb
    merriam-webster
    metacritic
    newyorker
    nymag
    nyt
    pcmag
    producthunt
    quora
    reddit
    reuters
    techcrunch
    techradar
    testfreaks
    theguardian
    theinformation
    theverge
    tomsguide
    tomshardware
    trustpilot
    venturebeat
    vice
    wikipedia
    wirecutter
    wired
    wsj
    yahoo
    youtube
    zdnet
  ).freeze

  def allow_result?(result)
    BLACKLISTED_DOMAINS.none? { |domain| result['link'].include?(domain) }
  end
end
