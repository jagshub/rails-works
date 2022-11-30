# frozen_string_literal: true

class API::V1::BasicCollectionSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :id,
    :name,
    :title,
    :created_at,
    :updated_at,
    :featured_at,
    :subscriber_count,
    to: :resource,
  )

  attributes(
    :background_image_url,
    :category_id,
    :collection_url,
    :color,
    :posts_count,
    :user,
  )

  def collection_url
    Routes.collection_url(resource, Metrics.url_tracking_params(medium: :api, object: scope[:current_application]))
  end

  def posts_count
    resource.posts.count
  end

  def user
    API::V1::BasicUserSerializer.new(resource.user, scope)
  end

  def background_image_url
    resource.background_image_banner_url
  end

  # NOTE(rstankov): Backward compatibility, collections used to have color column
  def color
    'blue'
  end

  # NOTE(rstankov): Backward compatibility, collections used to have category id column
  def category_id
    nil
  end
end
