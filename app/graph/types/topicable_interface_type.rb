# frozen_string_literal: true

module Graph::Types
  module TopicableInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'Topicable'

    field :id, ID, null: false
    field :topic_ids, [ID], null: false

    # NOTE(rstankov): `to_a` is required in order for prevent double fetching of topics
    # The reason `AssociationResolver` is used, because we actually load all topics
    field :topics, max_page_size: 20, resolver: ::Graph::Utils::AssociationResolver.call(preload: :topics, type: Graph::Types::TopicType.connection_type, null: false, handler: ->(assoc) { assoc.to_a })
  end
end
