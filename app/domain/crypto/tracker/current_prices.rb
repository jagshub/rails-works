# frozen_string_literal: true

class Crypto::Tracker::CurrentPrices
  def self.fetch
    Crypto::CurrencyTracker
      .select('DISTINCT ON (token_id) *')
      .order(:token_id, created_at: :desc).collect
  end
end
