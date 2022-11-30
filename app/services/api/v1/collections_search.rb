# frozen_string_literal: true

class API::V1::CollectionsSearch
  include SearchObject.module
  include API::V1::Sorting

  scope { Collection.with_preloads.all }

  option :slug
  option :user_id
  option :user_username, with: :apply_username_filter
  option :featured, with: :apply_featured_filter
  option :subscriber_id, with: :apply_subscriber_id_filter
  option :post_id, with: :apply_post_id_filter

  sort_by :id, :created_at, :updated_at, :featured_at

  private

  def apply_username_filter(scope, value)
    scope.joins(:user).where('users.username' => value)
  end

  def apply_featured_filter(scope, value)
    scope.featured if value
  end

  def apply_subscriber_id_filter(scope, value)
    scope.joins(:subscriptions).where('collection_subscriptions.user_id' => value)
  end

  def apply_post_id_filter(scope, value)
    scope.joins(:collection_post_associations).where('collection_post_associations.post_id' => value)
  end
end
