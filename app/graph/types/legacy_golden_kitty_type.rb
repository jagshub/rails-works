# frozen_string_literal: true

module Graph::Types
  class LegacyGoldenKittyType < BaseObject
    graphql_name 'LegacyGoldenKitty'

    field :product, [Graph::Types::PostType], null: true
    field :mobile, [Graph::Types::PostType], null: true
    field :hardware, [Graph::Types::PostType], null: true
    field :bot, [Graph::Types::PostType], null: true
    field :crypto, [Graph::Types::PostType], null: true
    field :ar, [Graph::Types::PostType], null: true
    field :sideproject, [Graph::Types::PostType], null: true
    field :lifehack, [Graph::Types::PostType], null: true
    field :designtool, [Graph::Types::PostType], null: true
    field :consumer, [Graph::Types::PostType], null: true
    field :breakout, [Graph::Types::PostType], null: true
    field :devtool, [Graph::Types::PostType], null: true
    field :b2b, [Graph::Types::PostType], null: true
    field :wtf, [Graph::Types::PostType], null: true

    field :community, [Graph::Types::UserType], null: true
    field :maker, [Graph::Types::UserType], null: true
  end
end
