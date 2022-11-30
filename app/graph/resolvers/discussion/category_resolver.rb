# frozen_string_literal: true

class Graph::Resolvers::Discussion::CategoryResolver < Graph::Resolvers::BaseSearch
  scope { Discussion::Category.all }
  type Graph::Types::Discussion::CategoryType.connection_type, null: false

  option :slug, type: String, with: :for_slug
  option :has_discussions, type: Boolean, with: :apply_has_disucssions

  private

  def apply_has_disucssions(scope, value)
    scope.having_discussions if value
  end

  def for_slug(scope, value)
    scope.where(slug: value)
  end
end
