# frozen_string_literal: true

module API::V2Internal::Types
  class Ads::ChannelType < BaseObject
    graphql_name 'AdChannel'

    implements GraphQL::Types::Relay::Node

    field :post, API::V2Internal::Types::PostType, null: true

    field :id, ID, null: false
    field :name, String, null: false
    field :tagline, String, null: false
    field :cta_text, String, null: true
    field :thumbnail_uuid, String, null: false
    field :url, String, null: false
  end
end
