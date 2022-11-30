# frozen_string_literal: true

class Graph::Resolvers::Web3::PostsResolver < Graph::Resolvers::BaseSearch
  AVAILABLE_TOPICS = %i(web3 dao dapp defi ethereum bitcoin nft cryptocurrency blockchain crypto).freeze

  scope do
    Post
      .featured
      .alive
      .joins(:topics)
      .where(topics: { slug: AVAILABLE_TOPICS })
      .distinct
  end

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'Web3PostsOrder'

    value 'NEWEST', 'Sort by the newest'
    value 'POPULAR', 'Sort by the highest votes'
    value 'TRENDING', 'Sort by trending posts'
  end

  class KindType < Graph::Types::BaseEnum
    graphql_name 'Web3PostsKind'

    value 'EVERYTHING', 'Sort by all'
    value 'DAO', 'Sort by DAO'
    value 'DAPP', 'Sort by DApps'
    value 'DEFI', 'Sort by DeFi'
    value 'NFT', 'Sort by NFT'
    value 'CRYPTOCURRENCY', 'Sort by Cryptocurrency'
    value 'BLOCKCHAIN', 'Sort by Blockchain'
    value 'BITCOIN', 'Sort by Bitcoin support'
    value 'ETHEREUM', 'Sort by Ethereum support'
  end

  option :order, type: OrderType, default: 'NEWEST'
  option :kind, type: KindType, default: 'EVERYTHING'

  def apply_order_with_newest(scope)
    scope.by_featured_at
  end

  def apply_order_with_popular(scope)
    scope.order(credible_votes_count: :desc)
  end

  def apply_order_with_trending(scope)
    scope.select("posts.*, (#{ ::Posts::Ranking.algorithm_in_sql }) as rank").order('rank DESC').order('scheduled_at DESC')
  end

  def apply_kind_with_everything(scope)
    scope
  end

  def apply_kind_with_dao(scope)
    scope.where('topics.slug' => :dao)
  end

  def apply_kind_with_dapp(scope)
    scope.where('topics.slug' => :dapp)
  end

  def apply_kind_with_defi(scope)
    scope.where('topics.slug' => :defi)
  end

  def apply_kind_with_nft(scope)
    scope.where('topics.slug' => :nft)
  end

  def apply_kind_with_cryptocurrency(scope)
    scope.where('topics.slug' => :cryptocurrency)
  end

  def apply_kind_with_blockchain(scope)
    scope.where('topics.slug' => :blockchain)
  end

  def apply_kind_with_bitcoin(scope)
    scope.where('topics.slug' => :bitcoin)
  end

  def apply_kind_with_ethereum(scope)
    scope.where('topics.slug' => :ethereum)
  end
end
