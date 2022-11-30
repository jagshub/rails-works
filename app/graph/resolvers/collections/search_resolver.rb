# frozen_string_literal: true

class Graph::Resolvers::Collections::SearchResolver < Graph::Resolvers::BaseSearch
  scope { object.present? ? object.collections.visible(current_user) : Collection.visible.visible(current_user) }

  type Graph::Types::CollectionType.connection_type, null: false

  option :featured, type: Boolean, with: :for_featured

  private

  def for_featured(scope, value)
    return scope unless value

    scope.by_feature_date.featured
  end
end
