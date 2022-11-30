# frozen_string_literal: true

class Graph::Resolvers::Web3::ChainResolver < Graph::Resolvers::Base
  type Graph::Types::Web3::ChainType, null: true

  def resolve
    ChainLoader.for.load(object)
  end

  CHAIN_TOPICS = %i(
    ethereum
    bitcoin
    solana
    polygon
    stacks
    tezos
    cardano
  ).freeze

  CHAIN_IMAGE = {
    bitcoin: 'crypto/1.png',
    ethereum: 'crypto/1027.png',
    solana: 'crypto/5426.png',
    polygon: 'crypto/3890.png',
    stacks: 'crypto/4847.png',
    tezos: 'crypto/2011.png',
    cardano: 'crypto/2010.png',
  }.freeze

  class ChainLoader < GraphQL::Batch::Loader
    def perform(posts)
      rows = PostTopicAssociation.joins(:topic).where('topics.slug' => CHAIN_TOPICS).where(post_id: posts.map(&:id)).pluck(Arel.sql('post_id, topics.slug, name'))

      chains = rows.inject({}) do |acc, row|
        acc[row[0]] = { name: row[2], image: CHAIN_IMAGE[row[1].to_sym] }
        acc
      end

      posts.each do |post|
        fulfill post, chains[post.id]
      end
    end
  end
end
