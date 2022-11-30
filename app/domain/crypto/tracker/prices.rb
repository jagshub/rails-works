# frozen_string_literal: true

class Crypto::Tracker::Prices < ApplicationJob
  include ActiveJobHandleNetworkErrors
  queue_as :default

  def perform
    too_recent = Crypto::CurrencyTracker.any? && Crypto::CurrencyTracker.maximum(:created_at) > 50.minutes.ago
    if too_recent
      Rails.logger.info(
        'External::CoinMarketCap data is too recent to refetch (less than 50 minutes ago).',
      )
    end
    return if too_recent

    response = fetch_prices
    return if response.nil?

    response.fetch('data').values.each do |token_info|
      next unless Crypto::CurrencyTracker.can_refresh?(token_info.fetch('id'))

      tracker_data = {
        token_id: token_info.fetch('id'),
        token_symbol: token_info.fetch('symbol'),
        token_name: token_info.fetch('name'),
        usd_price: token_info.fetch('quote').fetch('USD').fetch('price').to_f,
      }
      Crypto::CurrencyTracker.create!(tracker_data)
    end
  end

  private

  def fetch_prices
    Rails.logger.info(
      'External::CoinMarketCap API call from tracker/prices',
    )
    api_response = External::APIResponse.fetch(
      params: { token_ids: Crypto::Currency::TOKENS.keys, date: Time.zone.now.to_i },
      kind: :coinmarketcap,
    ) do
      External::CoinmarketcapAPI.prices(Crypto::Currency::TOKENS.keys)
    end

    api_response.response
  end
end
