# frozen_string_literal: true

class Graph::Resolvers::Topics::TopicsResolver < Graph::Resolvers::BaseSearch
  scope { Topic.by_followers_count.by_name }

  option :query, type: String, with: :for_query
  option :followed_by, type: GraphQL::Types::ID, with: :for_followed_by
  option :followed_by_viewer, type: Boolean, with: :for_followed_by_viewer
  option :order, type: String, with: :for_order
  option :ids, type: [ID], with: :include_ids
  option :exclude, type: [ID], with: :apply_exclude
  option :parent_only, type: Boolean, with: :apply_parent_only

  private

  def apply_parent_only(scope, value)
    return unless value

    scope.where(parent_id: nil)
  end

  def apply_exclude(scope, exclude)
    scope.where.not(id: exclude)
  end

  def for_followed_by(scope, value)
    return if value.blank?

    scope.joins(:subscriptions).where('subscriptions.subscriber_id' => User.find(value).subscriber.try(:id))
  end

  def for_followed_by_viewer(scope, value)
    return if value.blank?

    for_followed_by(scope, current_user.id) if current_user.present?
  end

  def for_query(scope, value)
    return if value.blank?

    # Note(AR): The `by_query` methods reorders, only then can we add the base orderings.
    scope.by_query(value).by_followers_count.by_name
  end

  def for_order(scope, value)
    case value
    when 'name' then scope.reorder(name: :asc)
    when 'stories_count' then scope.reorder(stories_count: :desc)
    when 'posts_count' then scope.reorder(posts_count: :desc)
    end
  end

  def include_ids(scope, value)
    return if value.empty?

    scope.where(id: value)
  end
end
