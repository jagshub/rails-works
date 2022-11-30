# frozen_string_literal: true

class API::V1::BasicPostSerializer < API::V1::BaseSerializer
  delegated_attributes(
    :comments_count,
    :id,
    :name,
    :product_state,
    :tagline,
    :slug,
    :votes_count,
    to: :resource,
  )

  attributes(
    :day,
    :category_id,
    :created_at,
    :current_user,
    :discussion_url,
    :exclusive,
    :featured,
    :ios_featured_at,
    :maker_inside,
    :makers,
    :platforms,
    :redirect_url,
    :screenshot_url,
    :thumbnail,
    :topics,
    :user,
  )

  delegate :product, to: :resource

  def user
    API::V1::BasicUserSerializer.new(resource.user, scope)
  end

  def makers
    API::V1::BasicUserSerializer.collection(resource.makers, scope, root: false)
  end

  def created_at
    # Note(andreasklinger): Since 2014-12 we use featured_at for sorting.
    #   To support old api clients we still support and communicate the usage of created_at
    resource.featured_at.presence || resource.scheduled_at
  end

  def featured
    resource.featured?
  end

  def day
    resource.featured_at.present? ? resource.featured_at.strftime('%Y-%m-%d') : nil
  end

  def discussion_url
    post_url(resource, Metrics.url_tracking_params(medium: :api, object: scope[:current_application]))
  end

  def redirect_url
    short_link_url(resource.short_code, resource.id, app_id: scope[:current_application].try(:id))
  end

  def maker_inside
    resource.maker_inside?
  end

  def ios_featured_at
    false
  end

  # NOTE(DZ): Backward compatibility, post now uses inline _uuid for thumbnails
  def thumbnail
    {
      id: "Thumbnail-#{ resource.id }",
      media_type: 'image',
      image_url: resource.thumbnail_url,
      metadata: OpenStruct.new(
        url: nil,
        kindle_asin: nil,
        video_id: nil,
        platform: nil,
      ),
    }
  end

  # NOTE(rstankov):  Backward compatibility, collections used to have exclusives
  def exclusive
    nil
  end

  # NOTE(rstankov): Backward compatibility, collections used to have category id column
  def category_id
    nil
  end

  def current_user
    return {} if scope[:current_user].blank?

    {
      voted_for_post: Voting.voted?(subject: resource, user: scope[:current_user]),
      commented_on_post: scope[:current_user].present? ? resource.comments.where(user_id: scope[:current_user].id).exists? : false,
    }
  end

  def screenshot_url
    {
      '300px' => Screenshot.new(resource.url).image_url(max_width: 300),
      '850px' => Screenshot.new(resource.url).image_url(max_width: 850),
    }
  end

  def platforms
    []
  end

  def topics
    API::V1::BasicTopicSerializer.collection(resource.topics, scope, root: false)
  end
end
