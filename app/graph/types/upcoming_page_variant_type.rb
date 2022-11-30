# frozen_string_literal: true

module Graph::Types
  class UpcomingPageVariantType < BaseObject
    graphql_name 'UpcomingPageVariant'

    field :id, ID, null: false
    field :kind, String, null: false
    field :who_text, Graph::Types::HTMLType, null: true
    field :what_text, Graph::Types::HTMLType, null: true
    field :why_text, Graph::Types::HTMLType, null: true
    field :brand_color, String, null: true
    field :logo_uuid, String, null: true
    field :background_image_uuid, String, null: true
    field :thumbnail_uuid, String, null: true
    field :unsplash_background_url, String, null: true
    field :subscriber_count, resolver: Graph::Resolvers::UpcomingPages::VariantSubscriberCountResolver
    field :subscriber_metrics, resolver: Graph::Resolvers::UpcomingPages::SubscriberMetricsResolver, null: false
    field :template_name, String, null: false
    field :background_color, String, null: true
    field :media, resolver: Graph::Resolvers::UpcomingPages::MediaResolver, null: true
  end
end
