# frozen_string_literal: true

class CollectionDigestPresenter::CollectionDecorator
  delegate :name, :user, :without_curator?, :recently_added_posts, to: :resource
  attr_reader :resource

  def initialize(collection)
    @resource = collection
  end

  def primary_post
    recently_added_posts.first
  end

  def secondary_posts
    return [] if total_post_count < 3

    recently_added_posts.limit(3).to_a.slice(1, 2)
  end

  def total_post_count
    recently_added_posts.size
  end

  def more?
    rest_posts_count > 0
  end

  def curator_name
    resource.user.first_name
  end

  def rest_posts_count
    total_post_count - secondary_posts.size - 1
  end
end
