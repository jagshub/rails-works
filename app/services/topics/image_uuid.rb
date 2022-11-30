# frozen_string_literal: true

class Topics::ImageUuid
  attr_reader :topic

  class << self
    def call(topic)
      new(topic).call
    end
  end

  def initialize(topic)
    @topic = topic
  end

  def call
    topic.image_uuid || most_upvoted_post_thumbnail_uuid
  end

  private

  def most_upvoted_post_thumbnail_uuid
    most_upvoted_post = topic.posts.by_credible_votes.first

    return if most_upvoted_post.blank?

    most_upvoted_post.thumbnail_image_uuid
  end
end
