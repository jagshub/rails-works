# frozen_string_literal: true

module Mobile::Graph::Types
  class Ads::ChannelType < BaseNode
    graphql_name 'AdChannel'

    field :post, PostType, null: true
    field :name, String, null: false
    field :tagline, String, null: false
    field :cta_text, String, null: true
    field :deal_text, String, null: true, deprecation_reason: 'no longer used when configuring ads'
    field :thumbnail_uuid, String, null: false
    field :url, String, null: false
    field :media, [MediaType], null: false

    def deal_text
      nil
    end
  end
end
