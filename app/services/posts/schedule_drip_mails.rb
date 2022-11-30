# frozen_string_literal: true

class Posts::ScheduleDripMails < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(post:)
    return unless post.makers.exists?(id: post.user_id)

    DripMails.begin_post_launch_drip(post: post)
  end
end
