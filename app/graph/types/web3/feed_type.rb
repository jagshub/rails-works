# frozen_string_literal: true

module Graph::Types
  class Web3::FeedType < BaseObject
    field :stats, Web3::StatsType, null: false
    field :token_prices, [Web3::TokenPriceType], null: false
    field :historical_prices, [Web3::TokenPriceType], null: true do
      argument :token_symbol, String, required: true
    end

    field :web3_posts,
          Graph::Types::PostType.connection_type,
          max_page_size: 20,
          resolver: Graph::Resolvers::Web3::PostsResolver, null: false,
          connection: true

    def stats
      valid_topic_slugs = Graph::Resolvers::Web3::PostsResolver::AVAILABLE_TOPICS

      {
        crypto_post_count: Topic.where(slug: valid_topic_slugs).sum(&:posts_count),
        crypto_followers_count: Topic.where(slug: valid_topic_slugs).sum(&:followers_count),
      }
    end

    def token_prices
      Crypto::Currency.current_prices
    end

    def historical_prices(token_symbol:)
      return if token_symbol.empty?

      Crypto::CurrencyTracker.where(token_symbol: token_symbol)
                             .order(created_at: :desc)
                             .limit(40)
                             .reverse
    end
  end
end
