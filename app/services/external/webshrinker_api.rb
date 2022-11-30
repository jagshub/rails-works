# frozen_string_literal: true

# Documentation
#
# - service: https://dashboard.webshrinker.com/
# - manage: https://dashboard.webshrinker.com/keys
# - api: https://docs.webshrinker.com/

module External::WebshrinkerAPI
  extend self

  include HTTParty
  base_uri 'https://api.webshrinker.com'

  def categories(url)
    return if url.blank?

    response = get(
      "/categories/v3/#{ Base64.strict_encode64(url) }",
      headers: httparty_headers,
    )
    return unless response.success?

    response.parsed_response
  end

  private

  def httparty_headers
    key = Config.secret(:webshrinker_key)
    secret = Config.secret(:webshrinker_secret)
    auth = "#{ key }:#{ secret }"

    { 'Authorization' => "Basic #{ Base64.strict_encode64(auth) }" }
  end
end
