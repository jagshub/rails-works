# frozen_string_literal: true

module Graph::Types
  class Web3::StatsType < BaseObject
    field :crypto_post_count, Integer, null: false
    field :crypto_followers_count, Integer, null: false
  end
end
