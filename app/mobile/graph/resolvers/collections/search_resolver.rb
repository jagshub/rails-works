# frozen_string_literal: true

class Mobile::Graph::Resolvers::Collections::SearchResolver < Mobile::Graph::Resolvers::BaseSearchResolver
  scope { object.present? ? object.collections : Collection.visible }

  type Mobile::Graph::Types::CollectionType.connection_type, null: false

  option :featured, type: Boolean, with: :for_featured

  private

  def for_featured(scope, value)
    return scope unless value

    scope.by_feature_date.featured
  end
end
