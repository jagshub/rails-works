# frozen_string_literal: true

module Mobile::Graph::Types
  module TopicableInterfaceType
    include Mobile::Graph::Types::BaseInterface

    graphql_name 'Topicable'

    field :id, ID, null: false
    field :topics, [Mobile::Graph::Types::TopicType], null: false
  end
end
