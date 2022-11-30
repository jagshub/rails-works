# frozen_string_literal: true

class Mobile::Graph::Types::Notifications::ContextType < Mobile::Graph::Types::BaseNode
  graphql_name 'DataContext'

  field :url, String, null: true
  field :type, String, null: true
  field :body, String, null: true
  field :image, String, null: true
end
