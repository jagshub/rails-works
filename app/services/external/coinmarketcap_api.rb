# frozen_string_literal: true

# Documentation
#
# - api: https://coinmarketcap.com/api/documentation/v1/
# - plan: BASIC - 10K credits per mo
#                 333 credits per day
#                 1 call = 1 credit

module External::CoinmarketcapAPI
  extend self

  include HTTParty
  base_uri 'https://pro-api.coinmarketcap.com'
  def prices(token_ids)
    return if token_ids.empty?

    response = get(
      "/v2/cryptocurrency/quotes/latest?id=#{ token_ids.join(',') }",
      headers: httparty_headers,
    )
    Rails.logger.info(
      'External::CoinMarketCap API call',
    )
    return unless response.success?

    response.parsed_response
  end

  private

  def httparty_headers
    { 'X-CMC_PRO_API_KEY' => Config.secret(:coinmarketcap_key) }
  end
end
