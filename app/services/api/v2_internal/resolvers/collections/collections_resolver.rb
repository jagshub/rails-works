# frozen_string_literal: true

class API::V2Internal::Resolvers::Collections::CollectionsResolver < API::V2Internal::Resolvers::BaseSearchResolver
  scope { object ? Collection.for_curator(user: object) : Collection.all }

  option :user_id, type: GraphQL::Types::ID, with: :for_user_id
  option :query, type: String, with: :for_query
  option :featured, type: Boolean, with: :for_featured
  option :followed_by, type: GraphQL::Types::ID, with: :for_followed_by
  option :order, type: String, with: :for_order

  private

  def for_user_id(scope, value)
    scope.for_curator(user_id: value)
  end

  def for_query(scope, value)
    scope.where('lower(name) LIKE ?', LikeMatch.simple(value)) if value
  end

  def for_featured(scope, value)
    scope.by_feature_date.featured if value
  end

  def for_followed_by(scope, value)
    scope.joins(:subscriptions).where('collection_subscriptions.user_id' => value, 'collection_subscriptions.state' => CollectionSubscription.states['subscribed']).order(id: :desc)
  end

  def for_order(scope, value)
    case value
    when 'name' then scope.reorder(name: :asc)
    end
  end
end
