# frozen_string_literal: true

class Mobile::Graph::Types::Notifications::TargetType < Mobile::Graph::Types::BaseNode
  graphql_name 'DataTarget'

  field :url, String, null: true
  field :type, String, null: true
  field :title, String, null: true
end
