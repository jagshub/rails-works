# frozen_string_literal: true

module Graph::Resolvers
  class Viewer::CollectionsSearchResolver < BaseSearch
    scope { current_user ? current_user.collections : [] }

    type Graph::Types::CollectionType.connection_type, null: false

    option :query, type: String, with: :apply_query

    def apply_query(scope, value)
      return scope if value.blank?

      scope.where_like_slow(:name, value)
    end
  end
end
