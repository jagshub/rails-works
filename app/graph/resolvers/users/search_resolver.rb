# frozen_string_literal: true

class Graph::Resolvers::Users::SearchResolver < Graph::Resolvers::BaseSearch
  scope { User.not_trashed }

  option :query, type: String, with: :apply_query
  option :exclude, type: [GraphQL::Types::ID], with: :apply_exclude

  private

  def apply_query(scope, query)
    scope.find_query(query)
  end

  def apply_exclude(scope, exclude)
    scope.where.not(id: exclude)
  end
end
