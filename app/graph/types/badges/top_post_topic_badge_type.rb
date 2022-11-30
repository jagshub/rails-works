# frozen_string_literal: true

module Graph::Types
  class Badges::TopPostTopicBadgeType < BaseObject
    graphql_name 'TopPostTopicBadge'

    field :id, ID, null: false
    field :position, Int, null: false
    field :topic_name, String, null: false
    field :period, String, null: false
    field :date, DateType, null: true
    association :post, Graph::Types::PostType, null: false, preload: :subject
  end
end
