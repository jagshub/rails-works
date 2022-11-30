# frozen_string_literal: true

class API::V1::UserSerializer < API::V1::BasicUserSerializer
  attributes(
    :collections_count,
    :followed_topics_count,
    :followers,
    :followers_count,
    :followings,
    :followings_count,
    :header_image_url,
    :maker_of,
    :maker_of_count,
    :posts,
    :posts_count,
    :votes,
    :votes_count,
  )

  def products
    resource.products.visible.with_preloads_for_api.by_date
  end

  def votes
    return [] if exclude? 'relationships'

    API::V1::VoteWithPostSerializer.collection(votes_array, scope, root: false)
  end

  def posts
    return [] if exclude? 'relationships'

    API::V1::BasicPostSerializer.collection(posts_array, scope, root: false)
  end

  def followers
    return [] if exclude? 'relationships'

    API::V1::BasicUserSerializer.collection(followers_array, scope, root: false)
  end

  def followings
    return [] if exclude? 'relationships'

    API::V1::BasicUserSerializer.collection(followings_array, scope, root: false)
  end

  delegate :votes_count, to: :resource

  delegate :posts_count, to: :resource

  def followers_count
    resource.follower_count
  end

  def followings_count
    resource.friend_count
  end

  def followed_topics_count
    0
  end

  delegate :collections_count, to: :resource

  def maker_of
    return [] if exclude? 'relationships'

    API::V1::BasicPostSerializer.collection(maker_of_array, scope, root: false)
  end

  def maker_of_count
    maker_of_array.size
  end

  def header_image_url
    Image.call resource.header_uuid
  end

  private

  def serialize_attributes
    if exclude? 'relationships'
      super.except :maker_of, :votes, :posts, :followers, :followings
    else
      super
    end
  end

  def maker_of_array
    resource.products.visible.reverse
  end

  def posts_array
    resource
      .posts
      .featured
      .with_preloads_for_api
      .last(10)
  end

  def followers_array
    resource
      .followers
      .with_preloads
      .last(10)
  end

  def followings_array
    resource
      .friends
      .with_preloads
      .last(10)
  end

  def votes_array
    Voting.votes_by(resource, type: :post, as_seen_by: scope[:current_user]).includes(:user, subject: Post.preload_attributes_for_api).last(10)
  end
end
