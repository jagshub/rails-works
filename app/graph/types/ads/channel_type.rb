# frozen_string_literal: true

module Graph::Types
  class Ads::ChannelType < BaseObject
    graphql_name 'AdChannel'

    field :id, ID, null: false
    field :post, PostType, null: true
    field :name, String, null: false
    field :tagline, String, null: false
    field :cta_text, String, null: true
    field :deal_text, String, null: true, deprecation_reason: 'no longer used when configuring ads'
    field :thumbnail_uuid, String, null: false
    field :url, String, null: false

    field :channel_kind, String, null: false

    def deal_text
      nil
    end
  end
end
