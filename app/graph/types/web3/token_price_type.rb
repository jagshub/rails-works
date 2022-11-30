# frozen_string_literal: true

module Graph::Types
  class Web3::TokenPriceType < BaseObject
    field :id, ID, null: false
    field :token_id, Integer, null: false
    field :token_name, String, null: false
    field :token_symbol, String, null: false
    field :usd_price, Float, null: false
    field :created_at, DateType, null: false
  end
end
