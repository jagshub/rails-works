# frozen_string_literal: true

module Crypto::Currency
  extend self

  # Note(TC): This is the list of tokens we will be tracking. This selection is so that we can track
  # these tokens over time as well as be able to cache this data so the ticker banner is not constantly
  # showing new tokens. These IDs are CoinmarketCap token IDs and not internal IDs.
  TOKENS = {
    1 => { symbol: 'BTC', name: 'Bitcoin' },
    1027 => { symbol: 'ETH', name: 'Ethereum' },
    825 => { symbol: 'USDT', name: 'Tether' },
    5426 => { symbol: 'SOL', name: 'Solana' },
    3890 => { symbol: 'MATIC', name: 'Polygon' },
    2011 => { symbol: 'XTZ', name: 'Tezos' },
    2010 => { symbol: 'ADA', name: 'Cardano' },
    6636 => { symbol: 'DOT', name: 'Polkadot' },
    52 => { symbol: 'XRP', name: 'XRP' },
    5805 => { symbol: 'AVAX', name: 'Avalanche' },
    74 => { symbol: 'DOGE', name: 'Dogecoin' },
    2308 => { symbol: 'SAI', name: 'Single Collateral DAI' },
    4847 => { symbol: 'STX', name: 'Stacks' },
  }.freeze

  def refresh_prices_worker
    Crypto::Tracker::Prices
  end

  def current_prices
    Crypto::Tracker::CurrentPrices.fetch
  end
end
